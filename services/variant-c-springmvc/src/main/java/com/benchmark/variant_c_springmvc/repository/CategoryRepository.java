package com.benchmark.variant_c_springmvc.repository;


import com.benchmark.variant_c_springmvc.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoryRepository extends JpaRepository<Category, Long> { }
