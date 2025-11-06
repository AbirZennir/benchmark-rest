package com.benchmark.variantc.api;

import com.benchmark.variantc.domain.Item;
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
@RequestMapping("/api/items")
public class ItemController {

    @Autowired
    private ItemRepository itemRepository;

    @GetMapping
    public Page<Item> list(@RequestParam(defaultValue = "0") int page,
                           @RequestParam(defaultValue = "20") int size,
                           @RequestParam(required = false) Long categoryId) {
        PageRequest pageable = PageRequest.of(page, size);
        return (categoryId == null)
                ? itemRepository.findAll(pageable)
                : itemRepository.findByCategoryId(categoryId, pageable);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Item> byId(@PathVariable Long id) {
        return itemRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Item> create(@Valid @RequestBody Item payload) {
        Item saved = itemRepository.save(payload);
        return ResponseEntity.created(URI.create("/api/items/" + saved.getId())).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Item> update(@PathVariable Long id, @Valid @RequestBody Item payload) {
        Optional<Item> opt = itemRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();
        Item i = opt.get();
        i.setSku(payload.getSku());
        i.setName(payload.getName());
        i.setPrice(payload.getPrice());
        i.setStock(payload.getStock());
        i.setCategory(payload.getCategory());
        i.setUpdatedAt(payload.getUpdatedAt());
        return ResponseEntity.ok(itemRepository.save(i));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (!itemRepository.existsById(id)) return ResponseEntity.notFound().build();
        itemRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
