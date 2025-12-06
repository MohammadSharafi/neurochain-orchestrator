package com.neurochain.infrastructure.messaging;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * Event bus for workflow events using Redis
 */
@Component
public class EventBus {
    private final RedisTemplate<String, Object> redisTemplate;

    public EventBus(RedisTemplate<String, Object> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    /**
     * Publish an event
     */
    public void publish(String eventType, Map<String, Object> data) {
        redisTemplate.convertAndSend("neurochain:events:" + eventType, data);
    }

    /**
     * Subscribe to events (would use Redis pub/sub)
     */
    public void subscribe(String eventType, EventHandler handler) {
        // TODO: Implement Redis pub/sub subscription
    }

    public interface EventHandler {
        void handle(Map<String, Object> data);
    }
}

