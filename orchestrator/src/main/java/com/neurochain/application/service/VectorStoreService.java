package com.neurochain.application.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * AI Memory Nodes - Local vector store for embeddings and similarity search
 */
@Service
public class VectorStoreService {
    private static final Logger logger = LoggerFactory.getLogger(VectorStoreService.class);

    private final Map<String, VectorStore> stores = new ConcurrentHashMap<>();
    private final EmbeddingService embeddingService;

    public VectorStoreService(EmbeddingService embeddingService) {
        this.embeddingService = embeddingService;
    }

    /**
     * Get all vector stores
     */
    public List<VectorStore> getAllStores() {
        return new ArrayList<>(stores.values());
    }

    /**
     * Create a new vector store
     */
    public VectorStore createStore(String storeId, String name) {
        VectorStore store = new VectorStore(storeId, name);
        stores.put(storeId, store);
        logger.info("Created vector store: {}", storeId);
        return store;
    }

    /**
     * Add document to vector store
     */
    public void addDocument(String storeId, String documentId, String text, Map<String, Object> metadata) {
        VectorStore store = stores.get(storeId);
        if (store == null) {
            throw new RuntimeException("Vector store not found: " + storeId);
        }

        // Generate embedding
        float[] embedding = embeddingService.generateEmbedding(text);

        // Store document
        Document document = new Document(documentId, text, embedding, metadata);
        store.addDocument(document);

        logger.info("Added document {} to store {}", documentId, storeId);
    }

    /**
     * Search for similar documents
     */
    public List<SearchResult> similaritySearch(String storeId, String query, int topK) {
        VectorStore store = stores.get(storeId);
        if (store == null) {
            throw new RuntimeException("Vector store not found: " + storeId);
        }

        // Generate query embedding
        float[] queryEmbedding = embeddingService.generateEmbedding(query);

        // Calculate similarities
        List<SearchResult> results = new ArrayList<>();
        for (Document doc : store.getDocuments()) {
            double similarity = cosineSimilarity(queryEmbedding, doc.getEmbedding());
            results.add(new SearchResult(doc, similarity));
        }

        // Sort by similarity and return top K
        return results.stream()
                .sorted((a, b) -> Double.compare(b.getScore(), a.getScore()))
                .limit(topK)
                .toList();
    }

    /**
     * Calculate cosine similarity
     */
    private double cosineSimilarity(float[] a, float[] b) {
        if (a.length != b.length) {
            return 0.0;
        }

        double dotProduct = 0.0;
        double normA = 0.0;
        double normB = 0.0;

        for (int i = 0; i < a.length; i++) {
            dotProduct += a[i] * b[i];
            normA += a[i] * a[i];
            normB += b[i] * b[i];
        }

        return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
    }

    public static class VectorStore {
        private final String id;
        private final String name;
        private final List<Document> documents;

        public VectorStore(String id, String name) {
            this.id = id;
            this.name = name;
            this.documents = new ArrayList<>();
        }

        public void addDocument(Document document) {
            documents.add(document);
        }

        public String getId() { return id; }
        public String getName() { return name; }
        public List<Document> getDocuments() { return documents; }
    }

    public static class Document {
        private final String id;
        private final String text;
        private final float[] embedding;
        private final Map<String, Object> metadata;

        public Document(String id, String text, float[] embedding, Map<String, Object> metadata) {
            this.id = id;
            this.text = text;
            this.embedding = embedding;
            this.metadata = metadata;
        }

        public String getId() { return id; }
        public String getText() { return text; }
        public float[] getEmbedding() { return embedding; }
        public Map<String, Object> getMetadata() { return metadata; }
    }

    public static class SearchResult {
        private final Document document;
        private final double score;

        public SearchResult(Document document, double score) {
            this.document = document;
            this.score = score;
        }

        public Document getDocument() { return document; }
        public double getScore() { return score; }
    }
}

