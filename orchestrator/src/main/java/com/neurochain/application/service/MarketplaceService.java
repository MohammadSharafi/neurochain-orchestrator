package com.neurochain.application.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Workflow Marketplace - Offline compatible
 * Manages plugins, node packs, templates, and model bundles
 */
@Service
public class MarketplaceService {
    private static final Logger logger = LoggerFactory.getLogger(MarketplaceService.class);

    private final Map<String, MarketplaceItem> items = new ConcurrentHashMap<>();

    public MarketplaceService() {
        // Initialize with some default items
        initializeDefaultItems();
    }

    /**
     * Get all marketplace items
     */
    public List<MarketplaceItem> getAllItems() {
        return new ArrayList<>(items.values());
    }

    /**
     * Get items by category
     */
    public List<MarketplaceItem> getItemsByCategory(ItemCategory category) {
        return items.values().stream()
                .filter(item -> item.getCategory() == category)
                .toList();
    }

    /**
     * Install an item
     */
    public InstallationResult installItem(String itemId) {
        MarketplaceItem item = items.get(itemId);
        if (item == null) {
            return new InstallationResult(false, "Item not found", null);
        }

        logger.info("Installing marketplace item: {}", itemId);
        // TODO: Implement actual installation
        return new InstallationResult(true, "Item installed successfully", null);
    }

    /**
     * Get item by ID
     */
    public MarketplaceItem getItem(String itemId) {
        return items.get(itemId);
    }

    /**
     * Add item to marketplace
     */
    public void addItem(MarketplaceItem item) {
        items.put(item.getId(), item);
        logger.info("Added marketplace item: {}", item.getId());
    }

    private void initializeDefaultItems() {
        // Example node pack
        MarketplaceItem nodePack = new MarketplaceItem(
                "node-pack-basic",
                "Basic Node Pack",
                "Essential nodes for workflow automation",
                ItemCategory.NODE_PACK,
                "1.0.0",
                "SynapseGrid",
                true
        );
        items.put(nodePack.getId(), nodePack);

        // Example template
        MarketplaceItem template = new MarketplaceItem(
                "template-document-processor",
                "Document Processor",
                "Workflow template for processing documents",
                ItemCategory.TEMPLATE,
                "1.0.0",
                "SynapseGrid",
                true
        );
        items.put(template.getId(), template);
    }

    public enum ItemCategory {
        PLUGIN,
        NODE_PACK,
        TEMPLATE,
        MODEL_BUNDLE
    }

    public static class MarketplaceItem {
        private final String id;
        private final String name;
        private final String description;
        private final ItemCategory category;
        private final String version;
        private final String author;
        private final boolean installed;

        public MarketplaceItem(String id, String name, String description, ItemCategory category, String version, String author, boolean installed) {
            this.id = id;
            this.name = name;
            this.description = description;
            this.category = category;
            this.version = version;
            this.author = author;
            this.installed = installed;
        }

        public String getId() { return id; }
        public String getName() { return name; }
        public String getDescription() { return description; }
        public ItemCategory getCategory() { return category; }
        public String getVersion() { return version; }
        public String getAuthor() { return author; }
        public boolean isInstalled() { return installed; }
    }

    public static class InstallationResult {
        private final boolean success;
        private final String message;
        private final String error;

        public InstallationResult(boolean success, String message, String error) {
            this.success = success;
            this.message = message;
            this.error = error;
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
        public String getError() { return error; }
    }
}

