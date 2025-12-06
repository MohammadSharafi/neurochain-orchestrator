class GraphQLQueries {
  // Workflows
  static const String getWorkflows = '''
    query GetWorkflows {
      workflows {
        id
        name
        description
        status
        triggerType
        createdAt
        updatedAt
      }
    }
  ''';

  static const String getWorkflow = '''
    query GetWorkflow(\$id: ID!) {
      workflow(id: \$id) {
        id
        name
        description
        status
        nodes {
          id
          type
          name
          parameters
        }
        connections {
          id
          sourceNodeId
          targetNodeId
        }
      }
    }
  ''';

  // AI Sandbox
  static const String testNode = '''
    query TestNode(\$node: NodeInput!, \$inputs: JSON!) {
      testNode(node: \$node, inputs: \$inputs) {
        executionId
        success
        inputs
        outputs
        reasoning
        executionTimeMs
        errorMessage
        latencyStats {
          averageMs
          minMs
          maxMs
          sampleCount
        }
      }
    }
  ''';

  // Model Manager
  static const String getInstalledModels = '''
    query GetInstalledModels {
      installedModels {
        name
        installed
        sizeBytes
        path
      }
    }
  ''';

  static const String getModelInfo = '''
    query GetModelInfo(\$name: String!) {
      modelInfo(name: \$name) {
        name
        installed
        sizeBytes
        path
      }
    }
  ''';

  static const String benchmarkModel = '''
    query BenchmarkModel(\$name: String!) {
      benchmarkModel(name: \$name) {
        modelName
        tokensPerSecond
        latencyMs
        memoryMB
        timestamp
      }
    }
  ''';

  // Vector Stores
  static const String getVectorStores = '''
    query GetVectorStores {
      vectorStores {
        id
        name
        documentCount
      }
    }
  ''';

  static const String searchVectorStore = '''
    query SearchVectorStore(\$storeId: ID!, \$query: String!, \$topK: Int) {
      searchVectorStore(storeId: \$storeId, query: \$query, topK: \$topK) {
        documentId
        text
        score
        metadata
      }
    }
  ''';

  // Fine Tuning
  static const String getFineTuningJob = '''
    query GetFineTuningJob(\$jobId: ID!) {
      fineTuningJob(jobId: \$jobId) {
        jobId
        modelName
        method
        status
        progress
        outputModelPath
      }
    }
  ''';

  // Marketplace
  static const String getMarketplaceItems = '''
    query GetMarketplaceItems(\$category: ItemCategory) {
      marketplaceItems(category: \$category) {
        id
        name
        description
        category
        version
        author
        installed
      }
    }
  ''';

  // Time Travel Debugger
  static const String getExecutionTimeline = '''
    query GetExecutionTimeline(\$executionId: ID!) {
      executionTimeline(executionId: \$executionId) {
        executionId
        events {
          id
          nodeId
          type
          timestamp
          data
        }
      }
    }
  ''';

  static const String getIOHistory = '''
    query GetIOHistory(\$executionId: ID!, \$nodeId: ID!) {
      ioHistory(executionId: \$executionId, nodeId: \$nodeId) {
        timestamp
        inputs
        outputs
      }
    }
  ''';
}

