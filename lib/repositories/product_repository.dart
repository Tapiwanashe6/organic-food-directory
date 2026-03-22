import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sample product names by category
  static const Map<String, List<String>> productNames = {
    'Vegetables': [
      'Organic Spinach', 'Red Bell Pepper', 'Tomato', 'Cucumber', 'Carrot',
      'Broccoli', 'Cauliflower', 'Cabbage', 'Lettuce', 'Kale',
      'Zucchini', 'Eggplant', 'Asparagus', 'Green Beans', 'Peas',
      'Onion', 'Garlic', 'Potato', 'Sweet Potato', 'Radish',
      'Beet', 'Turnip', 'Spinach Blend', 'Mixed Greens', 'Bok Choy',
      'Celery', 'Parsnip', 'Leek', 'Squash', 'Pumpkin',
      'Corn', 'Okra', 'Avocado', 'Artichoke', 'Brussels Sprouts',
      'Kohl Rabi', 'Water Spinach', 'Mustard Greens', 'Collard Greens', 'Swiss Chard',
      'Arugula', 'Endive', 'Radicchio', 'Parsley', 'Cilantro',
      'Basil', 'Mint', 'Sage', 'Thyme', 'Rosemary',
      'Dill', 'Oregano', 'Tarragon', 'Chives', 'Bay Leaves'
    ],
    'Fruits': [
      'Red Apple', 'Green Apple', 'Banana', 'Orange', 'Lemon',
      'Lime', 'Mango', 'Papaya', 'Pineapple', 'Strawberry',
      'Blueberry', 'Raspberry', 'Blackberry', 'Watermelon', 'Cantaloupe',
      'Honeydew', 'Grapes', 'Kiwi', 'Coconut', 'Dragonfruit',
      'Guava', 'Passionfruit', 'Peach', 'Nectarine', 'Plum',
      'Apricot', 'Cherry', 'Date', 'Fig', 'Pomegranate',
      'Grapefruit', 'Tangerine', 'Clementine', 'Durian', 'Rambutan',
      'Lychee', 'Persimmon', 'Quince', 'Mulberry', 'Elderberry',
      'Acai Berry', 'Goji Berry', 'Cranberry', 'Gooseberry', 'Currant',
      'Tamarind', 'Jackfruit', 'Starfruit', 'Cherimoya', 'Kumquat'
    ],
    'Dairy': [
      'Whole Milk', 'Low-fat Milk', 'Skim Milk', 'Greek Yogurt', 'Regular Yogurt',
      'Cottage Cheese', 'Cheddar Cheese', 'Mozzarella Cheese', 'Brie Cheese', 'Feta Cheese',
      'Parmesan Cheese', 'Swiss Cheese', 'Gouda Cheese', 'Cream Cheese', 'Ricotta',
      'Butter', 'Ghee', 'Heavy Cream', 'Sour Cream', 'Buttermilk',
      'Kefir', 'Milk Powder', 'Evaporated Milk', 'Condensed Milk', 'Almond Milk',
      'Soy Milk', 'Oat Milk', 'Coconut Milk', 'Rice Milk', 'Cashew Milk',
      'Halloumi Cheese', 'Paneer Cheese', 'Mozzarella di Bufala', 'Burrata', 'Provolone',
      'Emmental', 'Manchego', 'Fontina', 'Gruyere', 'Roquefort',
      'Blue Cheese', 'Camembert', 'Taleggio', 'Pecorino', 'Asiago'
    ],
    'Grains': [
      'Brown Rice', 'White Rice', 'Basmati Rice', 'Jasmine Rice', 'Arborio Rice',
      'Wild Rice', 'Black Rice', 'Red Rice', 'Wheat Flour', 'Whole Wheat Flour',
      'Oats', 'Barley', 'Quinoa', 'Millet', 'Sorghum',
      'Buckwheat', 'Rye', 'Amaranth', 'Lentils', 'Chickpeas',
      'Split Peas', 'Black Beans', 'Kidney Beans', 'Pinto Beans', 'Great Northern Beans',
      'Navy Beans', 'Cannellini Beans', 'Corn Meal', 'Polenta', 'Couscous',
      'Farro', 'Spelt', 'Teff', 'Kamut', 'Freekeh',
      'Bread Flour', 'Cake Flour', 'Pastry Flour', 'Semolina', 'Cornflour',
      'Tapioca', 'Arrowroot', 'Potato Starch', 'Wheat Germ', 'Bran'
    ],
    'Meat': [
      'Chicken Breast', 'Chicken Thighs', 'Chicken Drumsticks', 'Whole Chicken', 'Ground Chicken',
      'Beef Steak', 'Ground Beef', 'Beef Roast', 'Beef Ribs', 'Beef Brisket',
      'Pork Chops', 'Pork Ribs', 'Ground Pork', 'Pork Belly', 'Pork Tenderloin',
      'Lamb Chops', 'Ground Lamb', 'Lamb Leg', 'Lamb Shoulder', 'Lamb Ribs',
      'Turkey Breast', 'Ground Turkey', 'Turkey Legs', 'Turkey Wings', 'Whole Turkey',
      'Duck Breast', 'Whole Duck', 'Quail', 'Pheasant', 'Guinea Fowl',
      'Salmon', 'Trout', 'Cod', 'Tilapia', 'Tuna',
      'Shrimp', 'Crab', 'Lobster', 'Mussels', 'Oysters',
      'Bacon', 'Sausage', 'Ham', 'Salami', 'Prosciutto'
    ],
    'Organic': [
      'Organic Apple', 'Organic Banana', 'Organic Carrot', 'Organic Broccoli', 'Organic Tomato',
      'Organic Spinach Bundle', 'Organic Lettuce', 'Organic Cucumber', 'Organic Bell Pepper', 'Organic Onion',
      'Organic Garlic', 'Organic Potato', 'Organic Zucchini', 'Organic Eggplant', 'Organic Green Beans',
      'Organic Peas', 'Organic Kale', 'Organic Cabbage', 'Organic Cauliflower', 'Organic Asparagus',
      'Organic Orange', 'Organic Lemon', 'Organic Lime', 'Organic Strawberry', 'Organic Blueberry',
      'Organic Raspberries', 'Organic Blackberries', 'Organic Watermelon', 'Organic Cantaloupe', 'Organic Grapes',
      'Organic Rice', 'Organic Wheat Flour', 'Organic Oats', 'Organic Quinoa', 'Organic Lentils',
      'Organic Chickpeas', 'Organic Black Beans', 'Organic Honey', 'Organic Olive Oil', 'Organic Coconut Oil',
      'Organic Almond Butter', 'Organic Peanut Butter', 'Organic Seeds', 'Organic Nuts Mix', 'Organic Tea'
    ],
  };

  // Generate mock products for testing
  List<ProductModel> _generateMockProducts() {
    final products = <ProductModel>[];
    int id = 0;
    
    productNames.forEach((category, names) {
      for (var name in names) {
        products.add(ProductModel(
          id: 'prod_$id',
          name: name,
          sub: 'Fresh organic quality',
          price: '\$${(3.50 + (id % 12)).toStringAsFixed(2)}',
          category: category,
          image: 'https://via.placeholder.com/250?text=${Uri.encodeComponent(name)}',
        ));
        id++;
      }
    });
    
    return products;
  }

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snap = await _firestore.collection('products').get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching from Firestore: $e');
    }
    // Return mock data if Firestore is empty or has error
    return _generateMockProducts();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final all = await getAllProducts();
    final q = query.toLowerCase();
    return all.where((p) => p.name.toLowerCase().contains(q) || p.sub.toLowerCase().contains(q)).toList();
  }

  Future<ProductModel> getProduct(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data() ?? {}, id);
      }
    } catch (e) {
      debugPrint('Error fetching product: $e');
    }
    // Return mock product if not found
    final all = _generateMockProducts();
    return all.firstWhere((p) => p.id == id, orElse: () => all.first);
  }
}