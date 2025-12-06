package com.neurochain.infrastructure.persistence.entity;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "vector_stores")
public class VectorStoreEntity {
    @Id
    private String id;
    
    private String name;
    
    @OneToMany(mappedBy = "store", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<DocumentEntity> documents;

    // Getters and setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public List<DocumentEntity> getDocuments() { return documents; }
    public void setDocuments(List<DocumentEntity> documents) { this.documents = documents; }
}

@Entity
@Table(name = "vector_store_documents")
public class DocumentEntity {
    @Id
    private String id;
    
    @ManyToOne
    @JoinColumn(name = "store_id")
    private VectorStoreEntity store;
    
    private String text;
    
    @Column(columnDefinition = "TEXT")
    private String embeddingJson; // JSON array of floats
    
    @Column(columnDefinition = "TEXT")
    private String metadataJson;

    // Getters and setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public VectorStoreEntity getStore() { return store; }
    public void setStore(VectorStoreEntity store) { this.store = store; }
    public String getText() { return text; }
    public void setText(String text) { this.text = text; }
    public String getEmbeddingJson() { return embeddingJson; }
    public void setEmbeddingJson(String embeddingJson) { this.embeddingJson = embeddingJson; }
    public String getMetadataJson() { return metadataJson; }
    public void setMetadataJson(String metadataJson) { this.metadataJson = metadataJson; }
}

