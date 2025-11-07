#!/usr/bin/env python3
"""
Génération des datasets CSV pour JMeter
- 2000 categories (IDs 1-2000)
- 100000 items (IDs 1-100000)
"""

import csv
import random
from pathlib import Path

# Configuration
CATEGORIES_COUNT = 2000
ITEMS_COUNT = 100000
ITEMS_PER_CATEGORY = 50  # Distribution moyenne

# Répertoire de sortie
OUTPUT_DIR = Path(__file__).parent

def generate_categories_csv():
    """Génère categories.csv avec 2000 IDs"""
    output_file = OUTPUT_DIR / "categories.csv"
    
    print(f"Génération de {output_file}...")
    
    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id'])
        
        for cat_id in range(1, CATEGORIES_COUNT + 1):
            writer.writerow([cat_id])
    
    print(f"✓ {CATEGORIES_COUNT} categories générées dans {output_file}")


def generate_items_csv():
    """Génère items.csv avec 100k IDs et leurs categoryIds"""
    output_file = OUTPUT_DIR / "items.csv"
    
    print(f"Génération de {output_file}...")
    
    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'categoryId'])
        
        # Distribution: ~50 items par catégorie
        for item_id in range(1, ITEMS_COUNT + 1):
            # Calcul de categoryId basé sur la distribution du data.sql
            # ((n - 1) % 2000) + 1
            category_id = ((item_id - 1) % CATEGORIES_COUNT) + 1
            writer.writerow([item_id, category_id])
    
    print(f"✓ {ITEMS_COUNT} items générés dans {output_file}")


def generate_categories_payloads_csv():
    """Génère categories_payloads.csv avec des payloads JSON variés"""
    output_file = OUTPUT_DIR / "categories_payloads.csv"
    
    print(f"Génération de {output_file}...")
    
    categories = [
        "Electronics", "Clothing", "Books", "Home", "Sports",
        "Toys", "Food", "Beauty", "Automotive", "Garden",
        "Office", "Pet", "Health", "Music", "Video Games"
    ]
    
    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['code', 'name'])
        
        # Générer 500 payloads variés pour la rotation
        for i in range(1, 501):
            code = f"CAT{str(i).zfill(4)}"
            name = f"{random.choice(categories)} {random.randint(1, 999)}"
            writer.writerow([code, name])
    
    print(f"✓ 500 payloads de categories générés dans {output_file}")


def generate_items_payloads_1kb():
    """Génère payloads_1KB.csv avec des payloads JSON ~1KB"""
    output_file = OUTPUT_DIR / "payloads_1KB.csv"
    
    print(f"Génération de {output_file}...")
    
    item_names = [
        "Laptop", "Smartphone", "Tablet", "Monitor", "Keyboard",
        "Mouse", "Headphones", "Speaker", "Camera", "Printer",
        "Router", "Smartwatch", "TV", "Console", "Drone"
    ]
    
    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['sku', 'name', 'price', 'stock', 'description'])
        
        # Générer 500 payloads ~1KB
        for i in range(1, 501):
            sku = f"SKU{str(i).zfill(8)}"
            name = f"{random.choice(item_names)} {random.randint(100, 999)}"
            price = round(random.uniform(10.0, 5000.0), 2)
            stock = random.randint(0, 500)
            # Description pour atteindre ~1KB
            description = f"High quality product with advanced features. " * 20
            writer.writerow([sku, name, price, stock, description])
    
    print(f"✓ 500 payloads 1KB générés dans {output_file}")


def generate_items_payloads_5kb():
    """Génère payloads_5KB.csv avec des payloads JSON ~5KB"""
    output_file = OUTPUT_DIR / "payloads_5KB.csv"
    
    print(f"Génération de {output_file}...")
    
    item_names = [
        "Premium Laptop", "Pro Smartphone", "Advanced Tablet", 
        "Professional Monitor", "Gaming Keyboard", "Wireless Mouse",
        "Studio Headphones", "Smart Speaker", "DSLR Camera", "Laser Printer"
    ]
    
    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['sku', 'name', 'price', 'stock', 'description', 'specifications'])
        
        # Générer 200 payloads ~5KB
        for i in range(1, 201):
            sku = f"SKU{str(i).zfill(8)}"
            name = f"{random.choice(item_names)} Model {random.randint(1000, 9999)}"
            price = round(random.uniform(50.0, 10000.0), 2)
            stock = random.randint(0, 200)
            
            # Description longue pour ~2.5KB
            description = (
                "This is a premium product designed for professionals and enthusiasts. "
                "It features cutting-edge technology, superior build quality, "
                "and exceptional performance in all conditions. " * 30
            )
            
            # Spécifications pour ~2.5KB supplémentaires
            specifications = (
                "Weight: 2.5kg | Dimensions: 30x20x5cm | Color: Black | "
                "Material: Aluminum | Warranty: 2 years | Battery: 10 hours | "
                "Connectivity: WiFi, Bluetooth 5.0, USB-C | " * 25
            )
            
            writer.writerow([sku, name, price, stock, description, specifications])
    
    print(f"✓ 200 payloads 5KB générés dans {output_file}")


def generate_random_selections():
    """Génère des fichiers avec sélections aléatoires pour tests"""
    
    # Sélection aléatoire de 1000 categories pour filtres
    print(f"Génération de categories_random.csv (1000 IDs aléatoires)...")
    output_file = OUTPUT_DIR / "categories_random.csv"
    
    random_cats = random.sample(range(1, CATEGORIES_COUNT + 1), 1000)
    
    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id'])
        for cat_id in sorted(random_cats):
            writer.writerow([cat_id])
    
    print(f"✓ Sélection aléatoire de 1000 categories générée")
    
    # Sélection aléatoire de 10000 items pour opérations ciblées
    print(f"Génération de items_random.csv (10000 IDs aléatoires)...")
    output_file = OUTPUT_DIR / "items_random.csv"
    
    random_items = random.sample(range(1, ITEMS_COUNT + 1), 10000)
    
    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id'])
        for item_id in sorted(random_items):
            writer.writerow([item_id])
    
    print(f"✓ Sélection aléatoire de 10000 items générée")


def main():
    print("=" * 60)
    print("Génération des datasets JMeter pour Benchmark REST")
    print("=" * 60)
    print()
    
    # Générer tous les fichiers CSV
    generate_categories_csv()
    print()
    
    generate_items_csv()
    print()
    
    generate_categories_payloads_csv()
    print()
    
    generate_items_payloads_1kb()
    print()
    
    generate_items_payloads_5kb()
    print()
    
    generate_random_selections()
    print()
    
    print("=" * 60)
    print("✓ Tous les datasets ont été générés avec succès!")
    print("=" * 60)
    print()
    print("Fichiers créés:")
    print(f"  - categories.csv           : {CATEGORIES_COUNT:,} IDs")
    print(f"  - items.csv                : {ITEMS_COUNT:,} IDs")
    print(f"  - categories_payloads.csv  : 500 payloads")
    print(f"  - payloads_1KB.csv         : 500 payloads ~1KB")
    print(f"  - payloads_5KB.csv         : 200 payloads ~5KB")
    print(f"  - categories_random.csv    : 1000 IDs aléatoires")
    print(f"  - items_random.csv         : 10000 IDs aléatoires")
    print()
    print("Ces fichiers peuvent être utilisés dans les plans JMeter avec CSV Data Set Config")


if __name__ == "__main__":
    main()
