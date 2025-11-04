package com.benchmark.variant_c_springmvc.controller;


import com.benchmark.variant_c_springmvc.entity.Category;
import com.benchmark.variant_c_springmvc.repository.CategoryRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/categories")
public class CategoryController {
    private final CategoryRepository repo;

    public CategoryController(CategoryRepository repo) { this.repo = repo; }

    @GetMapping
    public Page<Category> list(Pageable pageable) { return repo.findAll(pageable); }

    @GetMapping("/{id}")
    public Category get(@PathVariable Long id) { return repo.findById(id).orElseThrow(); }

    @PostMapping
    public Category create(@RequestBody Category c) { return repo.save(c); }

    @PutMapping("/{id}")
    public Category update(@PathVariable Long id, @RequestBody Category c) { c.setId(id); return repo.save(c); }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) { repo.deleteById(id); }
}
