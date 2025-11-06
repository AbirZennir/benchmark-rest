package com.benchmark.variant_a_jersey;

import org.glassfish.jersey.server.ResourceConfig;
import org.springframework.context.annotation.Configuration;

@Configuration
public class JerseyConfig extends ResourceConfig {
    public JerseyConfig() {
        // Register all JAX-RS resources in this package
        packages("com.benchmark.variant_a_jersey.api");
    }
}
