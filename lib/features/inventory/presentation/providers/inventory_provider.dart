import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/product_model.dart';

final productsProvider = StreamProvider<List<ProductModel>>((ref) async* {
  try {
    print('productsProvider: Starting...');
    
    // Ensure the box is open
    Box<ProductModel> box;
    try {
      if (Hive.isBoxOpen(AppConstants.productsBox)) {
        print('productsProvider: Box is already open');
        box = Hive.box<ProductModel>(AppConstants.productsBox);
      } else {
        print('productsProvider: Opening box...');
        box = await Hive.openBox<ProductModel>(AppConstants.productsBox);
        print('productsProvider: Box opened successfully');
      }
    } catch (e) {
      print('productsProvider: Error opening box: $e');
      rethrow;
    }
    
    // Add mock data if empty or has very few items
    if (box.isEmpty || box.length < 10) {
      print('Products box is empty or has few items (${box.length}). Adding mock data...');
      await box.clear();
      await _addMockProducts(box);
      print('Mock data added. Total products: ${box.length}');
    } else {
      print('Products box already has ${box.length} items');
    }
    
    // Initial data
    final products = box.values.toList();
    print('Yielding ${products.length} products to stream');
    print('First few products: ${products.take(3).map((p) => p.name).join(", ")}');
    yield products;
    
    // Listen to changes
    await for (final event in box.watch()) {
      final updatedProducts = box.values.toList();
      print('Box changed. New product count: ${updatedProducts.length}');
      yield updatedProducts;
    }
  } catch (e, stackTrace) {
    print('Error in productsProvider: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
});

Future<void> _addMockProducts(Box<ProductModel> box) async {
  print('Starting to add mock products...');
  final mockProducts = [
    // Electronics
    ProductModel.create(
      name: 'Laptop - Dell Inspiron 15',
      category: 'Electronics',
      barcode: '1234567890123',
      purchasePrice: 35000,
      sellingPrice: 45999.99,
      currentStock: 15,
      minStock: 5,
      unit: 'Piece',
      description: '15.6" Full HD, Intel Core i5, 8GB RAM, 512GB SSD',
      sku: 'ELE-LAP-001',
    ),
    ProductModel.create(
      name: 'Mouse - Logitech Wireless',
      category: 'Electronics',
      barcode: '1234567890124',
      purchasePrice: 800,
      sellingPrice: 1299.99,
      currentStock: 50,
      minStock: 10,
      unit: 'Piece',
      sku: 'ELE-MOU-001',
    ),
    ProductModel.create(
      name: 'Keyboard - Mechanical RGB',
      category: 'Electronics',
      barcode: '1234567890125',
      purchasePrice: 2500,
      sellingPrice: 3499.99,
      currentStock: 25,
      minStock: 5,
      unit: 'Piece',
      sku: 'ELE-KEY-001',
    ),
    ProductModel.create(
      name: 'Smartphone - Samsung Galaxy A54',
      category: 'Electronics',
      barcode: '1234567890126',
      purchasePrice: 25000,
      sellingPrice: 32999.99,
      currentStock: 12,
      minStock: 3,
      unit: 'Piece',
      sku: 'ELE-PHO-001',
    ),
    ProductModel.create(
      name: 'Tablet - iPad Air',
      category: 'Electronics',
      barcode: '1234567890127',
      purchasePrice: 45000,
      sellingPrice: 58999.99,
      currentStock: 8,
      minStock: 2,
      unit: 'Piece',
      sku: 'ELE-TAB-001',
    ),
    ProductModel.create(
      name: 'Headphones - Sony WH-1000XM4',
      category: 'Electronics',
      barcode: '1234567890128',
      purchasePrice: 15000,
      sellingPrice: 19999.99,
      currentStock: 18,
      minStock: 5,
      unit: 'Piece',
      sku: 'ELE-HEA-001',
    ),
    ProductModel.create(
      name: 'Monitor - 24" Full HD',
      category: 'Electronics',
      barcode: '1234567890129',
      purchasePrice: 8000,
      sellingPrice: 12999.99,
      currentStock: 10,
      minStock: 3,
      unit: 'Piece',
      sku: 'ELE-MON-001',
    ),
    ProductModel.create(
      name: 'Power Bank - 20000mAh',
      category: 'Electronics',
      barcode: '1234567890130',
      purchasePrice: 1200,
      sellingPrice: 1999.99,
      currentStock: 35,
      minStock: 10,
      unit: 'Piece',
      sku: 'ELE-POW-001',
    ),
    ProductModel.create(
      name: 'USB Cable - Type C',
      category: 'Electronics',
      barcode: '1234567890131',
      purchasePrice: 150,
      sellingPrice: 299.99,
      currentStock: 100,
      minStock: 25,
      unit: 'Piece',
      sku: 'ELE-USB-001',
    ),
    ProductModel.create(
      name: 'Smart Watch - Fitness Tracker',
      category: 'Electronics',
      barcode: '1234567890132',
      purchasePrice: 3000,
      sellingPrice: 4999.99,
      currentStock: 22,
      minStock: 5,
      unit: 'Piece',
      sku: 'ELE-WAT-001',
    ),
    
    // Clothing
    ProductModel.create(
      name: 'T-Shirt - Cotton Black L',
      category: 'Clothing',
      barcode: '2234567890123',
      purchasePrice: 200,
      sellingPrice: 399.99,
      currentStock: 45,
      minStock: 10,
      unit: 'Piece',
      sku: 'CLO-TSH-001',
    ),
    ProductModel.create(
      name: 'Jeans - Blue Denim 32',
      category: 'Clothing',
      barcode: '2234567890124',
      purchasePrice: 800,
      sellingPrice: 1599.99,
      currentStock: 25,
      minStock: 5,
      unit: 'Piece',
      sku: 'CLO-JEA-001',
    ),
    ProductModel.create(
      name: 'Formal Shirt - White M',
      category: 'Clothing',
      barcode: '2234567890125',
      purchasePrice: 600,
      sellingPrice: 1199.99,
      currentStock: 30,
      minStock: 8,
      unit: 'Piece',
      sku: 'CLO-SHI-001',
    ),
    ProductModel.create(
      name: 'Jacket - Winter Leather',
      category: 'Clothing',
      barcode: '2234567890126',
      purchasePrice: 2500,
      sellingPrice: 4999.99,
      currentStock: 10,
      minStock: 2,
      unit: 'Piece',
      sku: 'CLO-JAC-001',
    ),
    ProductModel.create(
      name: 'Socks - Sports Pack of 3',
      category: 'Clothing',
      barcode: '2234567890127',
      purchasePrice: 100,
      sellingPrice: 199.99,
      currentStock: 80,
      minStock: 20,
      unit: 'Pack',
      sku: 'CLO-SOC-001',
    ),
    ProductModel.create(
      name: 'Cap - Baseball Style',
      category: 'Clothing',
      barcode: '2234567890128',
      purchasePrice: 150,
      sellingPrice: 299.99,
      currentStock: 40,
      minStock: 10,
      unit: 'Piece',
      sku: 'CLO-CAP-001',
    ),
    
    // Food & Beverages
    ProductModel.create(
      name: 'Coca Cola 500ml',
      category: 'Food & Beverages',
      barcode: '8901030865278',
      purchasePrice: 30,
      sellingPrice: 40,
      currentStock: 100,
      minStock: 20,
      unit: 'Bottle',
      sku: 'FOO-COK-001',
    ),
    ProductModel.create(
      name: 'Lays Chips - Classic 52g',
      category: 'Food & Beverages',
      barcode: '8901030526911',
      purchasePrice: 15,
      sellingPrice: 20,
      currentStock: 150,
      minStock: 30,
      unit: 'Packet',
      sku: 'FOO-LAY-001',
    ),
    ProductModel.create(
      name: 'Maggi Noodles 2 Min',
      category: 'Food & Beverages',
      barcode: '8901030526912',
      purchasePrice: 10,
      sellingPrice: 15,
      currentStock: 200,
      minStock: 50,
      unit: 'Packet',
      sku: 'FOO-MAG-001',
    ),
    ProductModel.create(
      name: 'Bread - Whole Wheat',
      category: 'Food & Beverages',
      barcode: '8901030526913',
      purchasePrice: 25,
      sellingPrice: 35,
      currentStock: 40,
      minStock: 10,
      unit: 'Packet',
      sku: 'FOO-BRE-001',
    ),
    ProductModel.create(
      name: 'Chocolate - Dairy Milk',
      category: 'Food & Beverages',
      barcode: '8901030526914',
      purchasePrice: 30,
      sellingPrice: 50,
      currentStock: 120,
      minStock: 30,
      unit: 'Bar',
      sku: 'FOO-CHO-001',
    ),
    ProductModel.create(
      name: 'Coffee - Nescafe 50g',
      category: 'Food & Beverages',
      barcode: '8901030526915',
      purchasePrice: 80,
      sellingPrice: 120,
      currentStock: 60,
      minStock: 15,
      unit: 'Jar',
      sku: 'FOO-COF-001',
    ),
    ProductModel.create(
      name: 'Tea - Red Label 250g',
      category: 'Food & Beverages',
      barcode: '8901030526916',
      purchasePrice: 100,
      sellingPrice: 150,
      currentStock: 45,
      minStock: 10,
      unit: 'Packet',
      sku: 'FOO-TEA-001',
    ),
    ProductModel.create(
      name: 'Biscuits - Marie Gold',
      category: 'Food & Beverages',
      barcode: '8901030526917',
      purchasePrice: 15,
      sellingPrice: 25,
      currentStock: 180,
      minStock: 40,
      unit: 'Packet',
      sku: 'FOO-BIS-001',
    ),
    ProductModel.create(
      name: 'Juice - Tropicana Orange 1L',
      category: 'Food & Beverages',
      barcode: '8901030526918',
      purchasePrice: 60,
      sellingPrice: 90,
      currentStock: 55,
      minStock: 15,
      unit: 'Bottle',
      sku: 'FOO-JUI-001',
    ),
    
    // Health & Beauty
    ProductModel.create(
      name: 'Hand Sanitizer 500ml',
      category: 'Health & Beauty',
      barcode: '5555555555555',
      purchasePrice: 120,
      sellingPrice: 200,
      currentStock: 75,
      minStock: 20,
      unit: 'Bottle',
      sku: 'HEA-SAN-001',
    ),
    ProductModel.create(
      name: 'Face Wash - Himalaya',
      category: 'Health & Beauty',
      barcode: '5555555555556',
      purchasePrice: 80,
      sellingPrice: 150,
      currentStock: 60,
      minStock: 15,
      unit: 'Tube',
      sku: 'HEA-FAC-001',
    ),
    ProductModel.create(
      name: 'Shampoo - Head & Shoulders',
      category: 'Health & Beauty',
      barcode: '5555555555557',
      purchasePrice: 200,
      sellingPrice: 350,
      currentStock: 35,
      minStock: 10,
      unit: 'Bottle',
      sku: 'HEA-SHA-001',
    ),
    ProductModel.create(
      name: 'Toothpaste - Colgate 150g',
      category: 'Health & Beauty',
      barcode: '5555555555558',
      purchasePrice: 50,
      sellingPrice: 90,
      currentStock: 90,
      minStock: 20,
      unit: 'Tube',
      sku: 'HEA-TOO-001',
    ),
    ProductModel.create(
      name: 'Body Lotion - Nivea 400ml',
      category: 'Health & Beauty',
      barcode: '5555555555559',
      purchasePrice: 150,
      sellingPrice: 250,
      currentStock: 45,
      minStock: 10,
      unit: 'Bottle',
      sku: 'HEA-LOT-001',
    ),
    ProductModel.create(
      name: 'Perfume - Deo Spray',
      category: 'Health & Beauty',
      barcode: '5555555555560',
      purchasePrice: 120,
      sellingPrice: 200,
      currentStock: 55,
      minStock: 15,
      unit: 'Bottle',
      sku: 'HEA-PER-001',
    ),
    
    // Home & Garden
    ProductModel.create(
      name: 'LED Bulb 9W',
      category: 'Home & Garden',
      barcode: '6666666666666',
      purchasePrice: 100,
      sellingPrice: 180,
      currentStock: 80,
      minStock: 20,
      unit: 'Piece',
      sku: 'HOM-LED-001',
    ),
    ProductModel.create(
      name: 'Plant Pot - Ceramic 6"',
      category: 'Home & Garden',
      barcode: '6666666666667',
      purchasePrice: 150,
      sellingPrice: 299,
      currentStock: 25,
      minStock: 5,
      unit: 'Piece',
      sku: 'HOM-POT-001',
    ),
    ProductModel.create(
      name: 'Garden Hose - 50ft',
      category: 'Home & Garden',
      barcode: '6666666666668',
      purchasePrice: 800,
      sellingPrice: 1499,
      currentStock: 15,
      minStock: 3,
      unit: 'Piece',
      sku: 'HOM-HOS-001',
    ),
    ProductModel.create(
      name: 'Door Mat - Coir',
      category: 'Home & Garden',
      barcode: '6666666666669',
      purchasePrice: 200,
      sellingPrice: 399,
      currentStock: 30,
      minStock: 8,
      unit: 'Piece',
      sku: 'HOM-MAT-001',
    ),
    ProductModel.create(
      name: 'Wall Clock - Designer',
      category: 'Home & Garden',
      barcode: '6666666666670',
      purchasePrice: 500,
      sellingPrice: 999,
      currentStock: 20,
      minStock: 5,
      unit: 'Piece',
      sku: 'HOM-CLO-001',
    ),
    ProductModel.create(
      name: 'Curtains - Cotton Set',
      category: 'Home & Garden',
      barcode: '6666666666671',
      purchasePrice: 1200,
      sellingPrice: 2499,
      currentStock: 12,
      minStock: 3,
      unit: 'Set',
      sku: 'HOM-CUR-001',
    ),
    ProductModel.create(
      name: 'Fertilizer - Organic 5kg',
      category: 'Home & Garden',
      barcode: '6666666666672',
      purchasePrice: 300,
      sellingPrice: 549,
      currentStock: 40,
      minStock: 10,
      unit: 'Bag',
      sku: 'HOM-FER-001',
    ),
    ProductModel.create(
      name: 'Garden Tools Set',
      category: 'Home & Garden',
      barcode: '6666666666673',
      purchasePrice: 1500,
      sellingPrice: 2999,
      currentStock: 8,
      minStock: 2,
      unit: 'Set',
      sku: 'HOM-TOO-001',
    ),
    
    // Sports & Outdoors
    ProductModel.create(
      name: 'Cricket Bat - Willow',
      category: 'Sports & Outdoors',
      barcode: '7777777777777',
      purchasePrice: 1500,
      sellingPrice: 2999,
      currentStock: 10,
      minStock: 2,
      unit: 'Piece',
      sku: 'SPO-BAT-001',
    ),
    ProductModel.create(
      name: 'Football - Synthetic',
      category: 'Sports & Outdoors',
      barcode: '7777777777778',
      purchasePrice: 800,
      sellingPrice: 1499,
      currentStock: 15,
      minStock: 3,
      unit: 'Piece',
      sku: 'SPO-FOO-001',
    ),
    ProductModel.create(
      name: 'Tennis Ball - Pack of 3',
      category: 'Sports & Outdoors',
      barcode: '7777777777779',
      purchasePrice: 150,
      sellingPrice: 299,
      currentStock: 50,
      minStock: 10,
      unit: 'Pack',
      sku: 'SPO-TEN-001',
    ),
    ProductModel.create(
      name: 'Badminton Racket',
      category: 'Sports & Outdoors',
      barcode: '7777777777780',
      purchasePrice: 600,
      sellingPrice: 1199,
      currentStock: 20,
      minStock: 5,
      unit: 'Piece',
      sku: 'SPO-BAD-001',
    ),
    ProductModel.create(
      name: 'Yoga Mat - 6mm',
      category: 'Sports & Outdoors',
      barcode: '7777777777781',
      purchasePrice: 400,
      sellingPrice: 799,
      currentStock: 35,
      minStock: 8,
      unit: 'Piece',
      sku: 'SPO-YOG-001',
    ),
    ProductModel.create(
      name: 'Dumbbell Set - 5kg',
      category: 'Sports & Outdoors',
      barcode: '7777777777782',
      purchasePrice: 1200,
      sellingPrice: 2499,
      currentStock: 12,
      minStock: 3,
      unit: 'Pair',
      sku: 'SPO-DUM-001',
    ),
    ProductModel.create(
      name: 'Swimming Goggles',
      category: 'Sports & Outdoors',
      barcode: '7777777777783',
      purchasePrice: 300,
      sellingPrice: 599,
      currentStock: 25,
      minStock: 6,
      unit: 'Piece',
      sku: 'SPO-SWI-001',
    ),
    ProductModel.create(
      name: 'Sports Bottle - 1L',
      category: 'Sports & Outdoors',
      barcode: '7777777777784',
      purchasePrice: 200,
      sellingPrice: 399,
      currentStock: 45,
      minStock: 10,
      unit: 'Piece',
      sku: 'SPO-BOT-001',
    ),
    
    // Toys & Games
    ProductModel.create(
      name: 'Lego Building Blocks',
      category: 'Toys & Games',
      barcode: '8888888888888',
      purchasePrice: 2000,
      sellingPrice: 3499,
      currentStock: 12,
      minStock: 3,
      unit: 'Set',
      sku: 'TOY-LEG-001',
    ),
    ProductModel.create(
      name: 'Playing Cards - Standard',
      category: 'Toys & Games',
      barcode: '8888888888889',
      purchasePrice: 50,
      sellingPrice: 99,
      currentStock: 100,
      minStock: 20,
      unit: 'Pack',
      sku: 'TOY-CAR-001',
    ),
    ProductModel.create(
      name: 'Board Game - Chess',
      category: 'Toys & Games',
      barcode: '8888888888890',
      purchasePrice: 400,
      sellingPrice: 799,
      currentStock: 18,
      minStock: 4,
      unit: 'Set',
      sku: 'TOY-CHE-001',
    ),
    ProductModel.create(
      name: 'Puzzle - 1000 pieces',
      category: 'Toys & Games',
      barcode: '8888888888891',
      purchasePrice: 300,
      sellingPrice: 599,
      currentStock: 25,
      minStock: 5,
      unit: 'Box',
      sku: 'TOY-PUZ-001',
    ),
    ProductModel.create(
      name: 'Remote Control Car',
      category: 'Toys & Games',
      barcode: '8888888888892',
      purchasePrice: 1500,
      sellingPrice: 2999,
      currentStock: 8,
      minStock: 2,
      unit: 'Piece',
      sku: 'TOY-RCC-001',
    ),
    ProductModel.create(
      name: 'Teddy Bear - Large',
      category: 'Toys & Games',
      barcode: '8888888888893',
      purchasePrice: 500,
      sellingPrice: 999,
      currentStock: 20,
      minStock: 5,
      unit: 'Piece',
      sku: 'TOY-TED-001',
    ),
    ProductModel.create(
      name: 'Action Figure Set',
      category: 'Toys & Games',
      barcode: '8888888888894',
      purchasePrice: 800,
      sellingPrice: 1599,
      currentStock: 15,
      minStock: 3,
      unit: 'Set',
      sku: 'TOY-ACT-001',
    ),
    ProductModel.create(
      name: 'Rubiks Cube',
      category: 'Toys & Games',
      barcode: '8888888888895',
      purchasePrice: 200,
      sellingPrice: 399,
      currentStock: 40,
      minStock: 10,
      unit: 'Piece',
      sku: 'TOY-RUB-001',
    ),
    
    // Books & Media
    ProductModel.create(
      name: 'Notebook - A4 Ruled',
      category: 'Books & Media',
      barcode: '9999999999999',
      purchasePrice: 80,
      sellingPrice: 149,
      currentStock: 75,
      minStock: 15,
      unit: 'Piece',
      sku: 'BOO-NOT-001',
    ),
    ProductModel.create(
      name: 'Novel - Fiction Bestseller',
      category: 'Books & Media',
      barcode: '9999999999998',
      purchasePrice: 200,
      sellingPrice: 399,
      currentStock: 20,
      minStock: 5,
      unit: 'Piece',
      sku: 'BOO-NOV-001',
    ),
    ProductModel.create(
      name: 'Textbook - Mathematics',
      category: 'Books & Media',
      barcode: '9999999999997',
      purchasePrice: 300,
      sellingPrice: 599,
      currentStock: 30,
      minStock: 8,
      unit: 'Piece',
      sku: 'BOO-TEX-001',
    ),
    ProductModel.create(
      name: 'Magazine - Monthly',
      category: 'Books & Media',
      barcode: '9999999999996',
      purchasePrice: 50,
      sellingPrice: 99,
      currentStock: 60,
      minStock: 15,
      unit: 'Copy',
      sku: 'BOO-MAG-001',
    ),
    ProductModel.create(
      name: 'Comic Book Set',
      category: 'Books & Media',
      barcode: '9999999999995',
      purchasePrice: 250,
      sellingPrice: 499,
      currentStock: 25,
      minStock: 5,
      unit: 'Set',
      sku: 'BOO-COM-001',
    ),
    ProductModel.create(
      name: 'DVD - Movie Collection',
      category: 'Books & Media',
      barcode: '9999999999994',
      purchasePrice: 400,
      sellingPrice: 799,
      currentStock: 15,
      minStock: 3,
      unit: 'Pack',
      sku: 'BOO-DVD-001',
    ),
    ProductModel.create(
      name: 'Music CD - Popular Album',
      category: 'Books & Media',
      barcode: '9999999999993',
      purchasePrice: 150,
      sellingPrice: 299,
      currentStock: 35,
      minStock: 8,
      unit: 'Piece',
      sku: 'BOO-MUS-001',
    ),
    ProductModel.create(
      name: 'Dictionary - English',
      category: 'Books & Media',
      barcode: '9999999999992',
      purchasePrice: 250,
      sellingPrice: 499,
      currentStock: 20,
      minStock: 5,
      unit: 'Piece',
      sku: 'BOO-DIC-001',
    ),
    
    // Office Supplies
    ProductModel.create(
      name: 'A4 Paper Ream (500 sheets)',
      category: 'Office Supplies',
      barcode: '9876543210123',
      purchasePrice: 200,
      sellingPrice: 350,
      currentStock: 50,
      minStock: 10,
      unit: 'Ream',
      sku: 'OFF-PAP-001',
    ),
    ProductModel.create(
      name: 'Ball Pen - Blue (Pack of 10)',
      category: 'Office Supplies',
      barcode: '9876543210124',
      purchasePrice: 50,
      sellingPrice: 100,
      currentStock: 200,
      minStock: 50,
      unit: 'Pack',
      sku: 'OFF-PEN-001',
    ),
    ProductModel.create(
      name: 'Stapler - Heavy Duty',
      category: 'Office Supplies',
      barcode: '9876543210125',
      purchasePrice: 300,
      sellingPrice: 599,
      currentStock: 15,
      minStock: 3,
      unit: 'Piece',
      sku: 'OFF-STA-001',
    ),
    ProductModel.create(
      name: 'Pencil Box Set',
      category: 'Office Supplies',
      barcode: '9876543210126',
      purchasePrice: 150,
      sellingPrice: 299,
      currentStock: 40,
      minStock: 10,
      unit: 'Set',
      sku: 'OFF-PEN-002',
    ),
    ProductModel.create(
      name: 'File Folder - Pack of 12',
      category: 'Office Supplies',
      barcode: '9876543210127',
      purchasePrice: 100,
      sellingPrice: 199,
      currentStock: 60,
      minStock: 15,
      unit: 'Pack',
      sku: 'OFF-FIL-001',
    ),
    ProductModel.create(
      name: 'Whiteboard Marker Set',
      category: 'Office Supplies',
      barcode: '9876543210128',
      purchasePrice: 200,
      sellingPrice: 399,
      currentStock: 30,
      minStock: 8,
      unit: 'Set',
      sku: 'OFF-MAR-001',
    ),
    ProductModel.create(
      name: 'Calculator - Scientific',
      category: 'Office Supplies',
      barcode: '9876543210129',
      purchasePrice: 800,
      sellingPrice: 1499,
      currentStock: 20,
      minStock: 5,
      unit: 'Piece',
      sku: 'OFF-CAL-001',
    ),
    ProductModel.create(
      name: 'Desk Organizer',
      category: 'Office Supplies',
      barcode: '9876543210130',
      purchasePrice: 400,
      sellingPrice: 799,
      currentStock: 15,
      minStock: 3,
      unit: 'Piece',
      sku: 'OFF-ORG-001',
    ),
    
    // Others
    ProductModel.create(
      name: 'Phone Cover - Transparent',
      category: 'Others',
      barcode: '1111111111111',
      purchasePrice: 50,
      sellingPrice: 149,
      currentStock: 100,
      minStock: 20,
      unit: 'Piece',
      sku: 'OTH-COV-001',
    ),
    ProductModel.create(
      name: 'Car Air Freshener',
      category: 'Others',
      barcode: '1111111111112',
      purchasePrice: 30,
      sellingPrice: 79,
      currentStock: 50,
      minStock: 10,
      unit: 'Piece',
      sku: 'OTH-AIR-001',
    ),
    ProductModel.create(
      name: 'Umbrella - Automatic',
      category: 'Others',
      barcode: '1111111111113',
      purchasePrice: 400,
      sellingPrice: 799,
      currentStock: 25,
      minStock: 5,
      unit: 'Piece',
      sku: 'OTH-UMB-001',
    ),
    ProductModel.create(
      name: 'Key Chain Set',
      category: 'Others',
      barcode: '1111111111114',
      purchasePrice: 100,
      sellingPrice: 199,
      currentStock: 80,
      minStock: 20,
      unit: 'Set',
      sku: 'OTH-KEY-001',
    ),
    ProductModel.create(
      name: 'Wallet - Leather',
      category: 'Others',
      barcode: '1111111111115',
      purchasePrice: 500,
      sellingPrice: 999,
      currentStock: 30,
      minStock: 8,
      unit: 'Piece',
      sku: 'OTH-WAL-001',
    ),
    ProductModel.create(
      name: 'Sunglasses - UV Protection',
      category: 'Others',
      barcode: '1111111111116',
      purchasePrice: 600,
      sellingPrice: 1199,
      currentStock: 20,
      minStock: 5,
      unit: 'Piece',
      sku: 'OTH-SUN-001',
    ),
    ProductModel.create(
      name: 'Travel Bag - 20L',
      category: 'Others',
      barcode: '1111111111117',
      purchasePrice: 1000,
      sellingPrice: 1999,
      currentStock: 15,
      minStock: 3,
      unit: 'Piece',
      sku: 'OTH-BAG-001',
    ),
    ProductModel.create(
      name: 'Belt - Genuine Leather',
      category: 'Others',
      barcode: '1111111111118',
      purchasePrice: 400,
      sellingPrice: 799,
      currentStock: 35,
      minStock: 8,
      unit: 'Piece',
      sku: 'OTH-BEL-001',
    ),
  ];
  
  print('Mock products array created with ${mockProducts.length} items');
  
  for (var i = 0; i < mockProducts.length; i++) {
    final product = mockProducts[i];
    await box.put(product.id, product);
    if (i % 10 == 0) {
      print('Added ${i + 1} products...');
    }
    // Add small delay to ensure unique timestamps
    await Future.delayed(const Duration(milliseconds: 2));
  }
  
  print('Finished adding all ${mockProducts.length} mock products');
}

final categoriesProvider = Provider<List<String>>((ref) {
  return [
    'Electronics',
    'Clothing',
    'Food & Beverages',
    'Health & Beauty',
    'Home & Garden',
    'Sports & Outdoors',
    'Toys & Games',
    'Books & Media',
    'Office Supplies',
    'Others',
  ];
});

final inventoryServiceProvider = Provider((ref) => InventoryService());

class InventoryService {
  Box<ProductModel>? _productsBox;
  
  Future<Box<ProductModel>> _getBox() async {
    if (_productsBox != null && _productsBox!.isOpen) {
      return _productsBox!;
    }
    
    if (Hive.isBoxOpen(AppConstants.productsBox)) {
      _productsBox = Hive.box<ProductModel>(AppConstants.productsBox);
    } else {
      _productsBox = await Hive.openBox<ProductModel>(AppConstants.productsBox);
    }
    
    return _productsBox!;
  }
  
  Future<void> addProduct(ProductModel product) async {
    final box = await _getBox();
    await box.put(product.id, product);
  }
  
  Future<void> updateProduct(ProductModel product) async {
    final box = await _getBox();
    await box.put(product.id, product.copyWith(updatedAt: DateTime.now()));
  }
  
  Future<void> deleteProduct(String productId) async {
    final box = await _getBox();
    await box.delete(productId);
  }
  
  Future<ProductModel?> getProduct(String productId) async {
    final box = await _getBox();
    return box.get(productId);
  }
  
  Future<void> updateStock(String productId, int newStock) async {
    final box = await _getBox();
    final product = box.get(productId);
    if (product != null) {
      await box.put(
        productId,
        product.copyWith(
          currentStock: newStock,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }
  
  Future<void> importProducts(List<ProductModel> products) async {
    final box = await _getBox();
    final Map<String, ProductModel> productsMap = {
      for (var product in products) product.id: product
    };
    await box.putAll(productsMap);
  }
  
  Future<List<ProductModel>> searchProducts(String query) async {
    final box = await _getBox();
    final products = box.values.toList();
    return products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.barcode.contains(query) ||
          product.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
  
  Future<List<ProductModel>> getLowStockProducts() async {
    final box = await _getBox();
    final products = box.values.toList();
    return products.where((product) => product.isLowStock).toList();
  }
  
  Future<List<ProductModel>> getOutOfStockProducts() async {
    final box = await _getBox();
    final products = box.values.toList();
    return products.where((product) => product.isOutOfStock).toList();
  }
  
  Future<List<ProductModel>> getProducts() async {
    final box = await _getBox();
    return box.values.toList();
  }
}