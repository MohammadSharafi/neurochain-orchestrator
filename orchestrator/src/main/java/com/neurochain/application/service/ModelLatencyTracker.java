package com.neurochain.application.service;

import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.DoubleAdder;

/**
 * Tracks model latency for performance monitoring
 */
@Component
public class ModelLatencyTracker {
    private final Map<String, LatencyData> latencyData = new ConcurrentHashMap<>();

    public void recordLatency(String nodeType, long latencyMs) {
        latencyData.computeIfAbsent(nodeType, k -> new LatencyData())
                .record(latencyMs);
    }

    public AISandboxService.LatencyStats getLatencyStats(String nodeType) {
        LatencyData data = latencyData.get(nodeType);
        if (data == null || data.getCount() == 0) {
            return null;
        }
        return new AISandboxService.LatencyStats(
                data.getAverage(),
                data.getMin(),
                data.getMax(),
                data.getCount()
        );
    }

    private static class LatencyData {
        private final DoubleAdder sum = new DoubleAdder();
        private final AtomicLong count = new AtomicLong();
        private volatile double min = Double.MAX_VALUE;
        private volatile double max = 0;

        public void record(long latencyMs) {
            sum.add(latencyMs);
            count.incrementAndGet();
            updateMinMax(latencyMs);
        }

        private synchronized void updateMinMax(long latencyMs) {
            if (latencyMs < min) min = latencyMs;
            if (latencyMs > max) max = latencyMs;
        }

        public double getAverage() {
            long cnt = count.get();
            return cnt > 0 ? sum.sum() / cnt : 0;
        }

        public double getMin() { return min == Double.MAX_VALUE ? 0 : min; }
        public double getMax() { return max; }
        public int getCount() { return (int) count.get(); }
    }
}

