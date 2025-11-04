package com.benchmark.variant_c_springmvc.controller;


import com.benchmark.variant_c_springmvc.entity.Item;
import com.benchmark.variant_c_springmvc.repository.ItemRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/items")
public class ItemController {
    private final ItemRepository repo;

    public ItemController(ItemRepository repo) { this.repo = repo; }

    @GetMapping
    public Page<Item> list(@RequestParam(required = false) Long categoryId, Pageable pageable) {
        if (categoryId != null) return repo.findByCategoryId(categoryId, pageable);
        return repo.findAll(pageable);
    }

    @GetMapping("/{id}")
    public Item get(@PathVariable Long id) { return repo.findById(id).orElseThrow(); }

    @PostMapping
    public Item create(@RequestBody Item i) { return repo.save(i); }

    @PutMapping("/{id}")
    public Item update(@PathVariable Long id, @RequestBody Item i) { i.setId(id); return repo.save(i); }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) { repo.deleteById(id); }
}
