BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  imageUrl TEXT
);
CREATE TABLE IF NOT EXISTS question_results (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  result_id INTEGER,
  question_id INTEGER,
  user_answer TEXT NOT NULL,
  correct_answer TEXT NOT NULL,
  FOREIGN KEY (result_id) REFERENCES results (id),
  FOREIGN KEY (question_id) REFERENCES questions (id)
);
CREATE TABLE IF NOT EXISTS questions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category_id INTEGER,
  question_text TEXT NOT NULL,
  correct_answer TEXT NOT NULL,
  options TEXT NOT NULL,
  explanation TEXT,
  image_url TEXT,
  FOREIGN KEY (category_id) REFERENCES categories (id)
);
CREATE TABLE IF NOT EXISTS results (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  category_id INTEGER,
  score INTEGER NOT NULL,
  total_questions INTEGER NOT NULL,
  date TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (category_id) REFERENCES categories (id)
);
CREATE TABLE IF NOT EXISTS user_progress (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  question_id INTEGER,
  is_correct BOOLEAN,
  review_date DATETIME,
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (question_id) REFERENCES questions (id)
);
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL
);
INSERT INTO "categories" ("id","name","description","imageUrl") VALUES (1,'Toán học','Các câu hỏi về đại số, hình học và các khái niệm toán học cơ bản','assets/images/math.png'),
 (2,'Vật lý','Kiến thức về cơ học, điện từ học và các định luật vật lý','assets/images/physics.png'),
 (3,'Hóa học','Các phản ứng hóa học, cấu tạo nguyên tử và bảng tuần hoàn','assets/images/chemistry.png'),
 (4,'Sinh học','Kiến thức về cơ thể người, động vật và thực vật','assets/images/biology.png'),
 (5,'Lịch sử','Các sự kiện lịch sử quan trọng của Việt Nam và thế giới','assets/images/history.png'),
 (6,'Địa lý','Kiến thức về địa lý tự nhiên và kinh tế xã hội','assets/images/geography.png');
INSERT INTO "questions" ("id","category_id","question_text","correct_answer","options","explanation","image_url") VALUES (1,1,'Phương trình x² + 2x + 1 = 0 có bao nhiêu nghiệm?','1','0|1|2|Vô số','Đây là phương trình (x + 1)² = 0, nên chỉ có một nghiệm x = -1',NULL),
 (2,1,'Tổng các góc trong tam giác là bao nhiêu độ?','180','90|180|270|360','Tổng các góc trong tam giác luôn bằng 180 độ',NULL),
 (3,1,'Diện tích hình tròn được tính bằng công thức nào? (Xem hình minh họa)','πr²','2πr|πr²|2πr²|πd','Công thức tính diện tích hình tròn là S = πr², trong đó r là bán kính','assets/images/math/circle.png'),
 (4,2,'Đơn vị đo lực là gì?','Newton','Pascal|Newton|Joule|Watt','Newton (N) là đơn vị đo lực trong hệ SI',NULL),
 (5,2,'Hãy xác định loại chuyển động trong hình','Chuyển động thẳng đều','Chuyển động tròn|Chuyển động thẳng đều|Chuyển động cong|Chuyển động biến đổi','Vật di chuyển trên một đường thẳng với vận tốc không đổi','assets/images/physics/velocity.png'),
 (6,2,'Định luật 3 Newton nói về điều gì?','Tác dụng và phản tác dụng','Quán tính|Gia tốc|Tác dụng và phản tác dụng|Vạn vật hấp dẫn','Định luật 3 Newton: Mọi tác dụng lực đều có phản tác dụng lực ngược chiều và có độ lớn bằng nhau',NULL),
 (7,3,'Công thức hóa học của nước là gì?','H₂O','CO₂|H₂O|O₂|N₂','Nước được tạo thành từ 2 nguyên tử Hydro và 1 nguyên tử Oxy','assets/images/chemistry/water.png'),
 (8,3,'Nguyên tố nào phổ biến nhất trong vỏ Trái Đất?','Oxy','Sắt|Oxy|Carbon|Silicon','Oxy chiếm khoảng 46.6% khối lượng vỏ Trái Đất','assets/images/chemistry/earth.png'),
 (9,3,'pH của dung dịch trung tính là bao nhiêu?','7','0|7|14|1','Dung dịch có pH = 7 được coi là trung tính','assets/images/chemistry/ph_scale.png'),
 (10,4,'Tim người có bao nhiêu ngăn?','4','2|3|4|5','Tim người có 4 ngăn: 2 tâm nhĩ và 2 tâm thất','assets/images/biology/heart.png'),
 (11,4,'Quá trình nào tạo ra năng lượng trong tế bào?','Hô hấp tế bào','Quang hợp|Hô hấp tế bào|Tiêu hóa|Bài tiết','Hô hấp tế bào là quá trình tạo ra ATP - nguồn năng lượng cho tế bào','assets/images/biology/cell.png'),
 (12,4,'DNA là viết tắt của?','Axit Deoxyribonucleic','Axit Ribonucleic|Axit Deoxyribonucleic|Axit Nucleic|Axit Amino','DNA là phân tử mang thông tin di truyền trong tế bào','assets/images/biology/dna.png'),
 (13,5,'Ai là người phát động phong trào Cần Vương?','Vua Hàm Nghi','Vua Tự Đức|Vua Hàm Nghi|Vua Duy Tân|Vua Thành Thái','Vua Hàm Nghi phát động phong trào Cần Vương năm 1885 chống Pháp','assets/images/history/ham_nghi.png'),
 (14,5,'Cách mạng tháng Tám diễn ra vào năm nào?','1945','1944|1945|1946|1947','Cách mạng tháng Tám thành công vào ngày 19/8/1945','assets/images/history/august_revolution.png'),
 (15,5,'Chiến thắng Điện Biên Phủ diễn ra vào năm nào?','1954','1953|1954|1955|1956','Chiến thắng Điện Biên Phủ kết thúc vào ngày 7/5/1954','assets/images/history/dien_bien_phu.png'),
 (16,6,'Đâu là con sông dài nhất Việt Nam?','Sông Mê Kông','Sông Hồng|Sông Mê Kông|Sông Đà|Sông Đồng Nai','Sông Mê Kông là con sông dài nhất chảy qua Việt Nam','assets/images/geography/mekong.png'),
 (17,6,'Việt Nam có bao nhiêu tỉnh thành?','63','61|62|63|64','Việt Nam có 63 tỉnh thành: 58 tỉnh và 5 thành phố trực thuộc trung ương','assets/images/geography/vietnam_map.png'),
 (18,6,'Đỉnh núi cao nhất Việt Nam là gì?','Fansipan','Fansipan|Phu Si|Ngọc Linh|Phu Luông','Fansipan cao 3143m, là đỉnh núi cao nhất Đông Dương','assets/images/geography/fansipan.png');
COMMIT;
