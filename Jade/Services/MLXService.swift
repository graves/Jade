//
//  MLXService.swift
//  MLXChatExample
//
//  Created by İbrahim Çetin on 20.04.2025.
//

import Foundation
import MLX
import MLXLLM
import MLXLMCommon
import MLXVLM

/// A service class that manages machine learning models for text and vision-language tasks.
/// This class handles model loading, caching, and text generation using various LLM and VLM models.
@Observable
class MLXService {
    /// List of available models that can be used for generation.
    /// Includes both language models (LLM) and vision-language models (VLM).
    static let availableModels: [LMModel] = [
        LMModel(name: "jade_qwen3_4bit:4b", configuration: LLMRegistry.jade_qwen3_4b_mlx_4bit, type: .llm),
        LMModel(name: "jade_qwen3_8bit:4b", configuration: LLMRegistry.jade_qwen3_4b_mlx_8bit, type: .llm),
        LMModel(name: "qwen3:4b", configuration: LLMRegistry.qwen3_4b_4bit, type: .llm),
        LMModel(name: "qwen3:8b", configuration: LLMRegistry.qwen3_8b_4bit, type: .llm),
    ]

    /// Cache to store loaded model containers to avoid reloading.
    private let modelCache = NSCache<NSString, ModelContainer>()

    /// Tracks the current model download progress.
    /// Access this property to monitor model download status.
    @MainActor
    private(set) var modelDownloadProgress: Progress?

    /// Loads a model from the hub or retrieves it from cache.
    /// - Parameter model: The model configuration to load
    /// - Returns: A ModelContainer instance containing the loaded model
    /// - Throws: Errors that might occur during model loading
    private func load(model: LMModel) async throws -> ModelContainer {
        // Set GPU memory limit to prevent out of memory issues
        MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)

        // Return cached model if available to avoid reloading
        if let container = modelCache.object(forKey: model.name as NSString) {
            return container
        } else {
            // Select appropriate factory based on model type
            let factory: ModelFactory =
                switch model.type {
                case .llm:
                    LLMModelFactory.shared
                case .vlm:
                    VLMModelFactory.shared
                }

            // Load model and track download progress
            let container = try await factory.loadContainer(
                hub: .default, configuration: model.configuration
            ) { progress in
                Task { @MainActor in
                    self.modelDownloadProgress = progress
                }
            }

            // Cache the loaded model for future use
            modelCache.setObject(container, forKey: model.name as NSString)

            return container
        }
    }

    /// Generates text based on the provided messages using the specified model.
    /// - Parameters:
    ///   - messages: Array of chat messages including user, assistant, and system messages
    ///   - model: The language model to use for generation
    /// - Returns: An AsyncStream of generated text tokens
    /// - Throws: Errors that might occur during generation
    func generate(messages: [Message], model: LMModel) async throws -> AsyncStream<Generation> {
        // Load or retrieve model from cache
        let modelContainer = try await load(model: model)

        // Map app-specific Message type to Chat.Message for model input
        let chat = messages.map { message in
            let role: Chat.Message.Role =
                switch message.role {
                case .assistant:
                    .assistant
                case .user:
                    .user
                case .system:
                    .system
                }

            // Process any attached media for VLM models
            let images: [UserInput.Image] = message.images.map { imageURL in .url(imageURL) }
            let videos: [UserInput.Video] = message.videos.map { videoURL in .url(videoURL) }

            return Chat.Message(
                role: role, content: message.content, images: images, videos: videos)
        }

        // Prepare input for model processing
        let userInput = UserInput(chat: chat)

        // Generate response using the model
        return try await modelContainer.perform { (context: ModelContext) in
            let lmInput = try await context.processor.prepare(input: userInput)
            // Set temperature for response randomness (0.7 provides good balance)
            let parameters = GenerateParameters(temperature: 0.7)

            return try MLXLMCommon.generate(
                input: lmInput, parameters: parameters, context: context)
        }
    }
}
