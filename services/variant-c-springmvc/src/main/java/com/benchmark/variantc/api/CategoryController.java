package com.benchmark.variantc.api;

import com.benchmark.variantc.domain.Category;
import com.benchmark.variantc.domain.Item;
import com.benchmark.variantc.repository.CategoryRepository;
import com.benchmark.variantc.repository.ItemRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.Optional;

@RestController
@RequestMapping("/api/categories")
public class CategoryController {

    @Autowired
    private CategoryRepository categoryRepository;
    @Autowired
    private ItemRepository itemRepository;

    @GetMapping
    public Page<Category> all(@RequestParam(defaultValue = "0") int page,
                              @RequestParam(defaultValue = "20") int size) {
        return categoryRepository.findAll(PageRequest.of(page, size));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Category> byId(@PathVariable Long id) {
        return categoryRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Category> create(@Valid @RequestBody Category payload) {
        Category saved = categoryRepository.save(payload);
        return ResponseEntity.created(URI.create("/api/categories/" + saved.getId())).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Category> update(@PathVariable Long id, @Valid @RequestBody Category payload) {
        Optional<Category> opt = categoryRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();
        Category c = opt.get();
        c.setCode(payload.getCode());
        c.setName(payload.getName());
        c.setUpdatedAt(payload.getUpdatedAt());
        return ResponseEntity.ok(categoryRepository.save(c));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (!categoryRepository.existsById(id)) return ResponseEntity.notFound().build();
        categoryRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/items")
    public Page<Item> itemsByCategory(@PathVariable Long id,
                                      @RequestParam(defaultValue = "0") int page,
                                      @RequestParam(defaultValue = "20") int size) {
        return itemRepository.findByCategoryId(id, PageRequest.of(page, size));
    }
}
