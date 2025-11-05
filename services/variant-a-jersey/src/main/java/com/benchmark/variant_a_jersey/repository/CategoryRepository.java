package com.benchmark.variant_a_jersey.repository;

import com.benchmark.variant_a_jersey.domain.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {
}
