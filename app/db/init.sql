-- =====================================================
-- init.sql — Schema & seed data Coffee Shop
-- Dijalankan otomatis oleh MySQL saat container pertama
-- kali dibuat (volume masih kosong).
-- =====================================================

CREATE TABLE IF NOT EXISTS menus (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  category ENUM('kopi','non-kopi','snack','dessert') NOT NULL,
  description TEXT,
  price INT NOT NULL,
  image_url VARCHAR(255),
  is_available BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO menus (name, category, description, price, image_url) VALUES
('Espresso', 'kopi', 'Single shot kopi arabika pekat dengan crema tebal', 18000, '/img/espresso.jpg'),
('Americano', 'kopi', 'Espresso disiram air panas, ringan dan bersih rasanya', 22000, '/img/americano.jpg'),
('Cappuccino', 'kopi', 'Perpaduan espresso, steamed milk, dan foam lembut', 28000, '/img/cappuccino.jpg'),
('Caffe Latte', 'kopi', 'Espresso dengan susu creamy, lembut untuk pemula', 28000, '/img/latte.jpg'),
('Kopi Susu Gula Aren', 'kopi', 'Kopi susu khas dengan gula aren asli Banten', 24000, '/img/kopi-susu.jpg'),
('Caffe Mocha', 'kopi', 'Espresso, cokelat premium, dan susu steam', 30000, '/img/mocha.jpg'),
('V60 Manual Brew', 'kopi', 'Kopi single origin diseduh manual, fruity dan aromatik', 35000, '/img/v60.jpg'),
('Matcha Latte', 'non-kopi', 'Matcha premium Jepang dengan susu segar', 30000, '/img/matcha.jpg'),
('Dark Chocolate', 'non-kopi', 'Cokelat panas pekat dari kakao 70%', 27000, '/img/chocolate.jpg'),
('Red Velvet Latte', 'non-kopi', 'Latte manis dengan rasa red velvet yang creamy', 27000, '/img/red-velvet.jpg'),
('Lemon Tea', 'non-kopi', 'Teh hitam dengan perasan lemon segar', 15000, '/img/lemon-tea.jpg'),
('Croissant Butter', 'snack', 'Croissant renyah buttery, pas untuk teman kopi', 25000, '/img/croissant.jpg'),
('French Fries', 'snack', 'Kentang goreng renyah dengan saus sambal & mayo', 20000, '/img/french-fries.jpg'),
('Pisang Goreng Madu', 'snack', 'Pisang goreng crispy dengan topping madu dan keju', 22000, '/img/pisang-goreng.jpg'),
('Chicken Katsu Sando', 'snack', 'Sandwich roti susu isi ayam katsu saus tonkatsu', 35000, '/img/sando.jpg'),
('Tiramisu Slice', 'dessert', 'Klasik tiramisu berlapis mascarpone dan kopi', 32000, '/img/tiramisu.jpg'),
('Choco Lava Cake', 'dessert', 'Cake cokelat lumer disajikan hangat dengan es krim vanila', 30000, '/img/lava-cake.jpg'),
('Cheesecake Blueberry', 'dessert', 'Baked cheesecake creamy dengan topping blueberry', 33000, '/img/cheesecake.jpg');
