BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  imageUrl TEXT
);
CREATE TABLE IF NOT EXISTS exam_question_results (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  exam_result_id INTEGER,
  question_id INTEGER,
  user_answer TEXT NOT NULL,
  correct_answer TEXT NOT NULL,
  FOREIGN KEY (exam_result_id) REFERENCES exam_results (id),
  FOREIGN KEY (question_id) REFERENCES questions (id)
);
CREATE TABLE IF NOT EXISTS exam_results (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  total_questions INTEGER NOT NULL,
  correct_answers INTEGER NOT NULL,
  time_spent INTEGER NOT NULL,
  timestamp TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id)
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
-- Categories
INSERT INTO "categories" ("id","name","description","imageUrl") VALUES
(1,'Java','Questions about Java programming language','assets/images/java.png'),
(2,'JavaScript','Questions about JavaScript programming language','assets/images/javascript.png'),
(3,'Kotlin','Questions about Kotlin programming language','assets/images/kotlin.png');

-- Môn Java
INSERT INTO questions (category_id, question_text, correct_answer, options, explanation, image_url) 
VALUES 
(1,'What is the default value of a local variable in Java?', 'No default value', '0|null|Undefined|No default value', 'Local variables in Java do not have a default value. You must initialize them before using.', 'NULLNULL'),
(1, 'Which of the following is a valid constructor in Java?', 'public Class() {}', 'public Class() {}|public Class() : {}|Class() {}|None of the above', 'In Java, constructors are declared like public Class() {}.', 'NULLNULL'),
(1, 'Which method is used to start a thread in Java?', 'start()', 'run()|start()|execute()|begin()', 'To start a thread, we use the start() method, not run().', 'NULLNULL'),
(1, 'What does the final keyword mean in Java?', 'The variable cannot be changed once initialized.', 'The method can be overridden.|The variable cannot be changed once initialized.|The class can be subclassed.|The method can throw exceptions.', 'The final keyword prevents modification of a variable, method, or class once initialized.', 'NULLNULL'),
(1, 'What will the following code snippet print?', '10', '10|11|Error|0', 'Post-increment means x will be printed first, then incremented.', 'assets/images/5.1.png'),
(1, 'Which of the following is not a Java data type?', 'real', 'int|float|double|real', 'The real data type does not exist in Java. Java uses float and double for floating-point numbers.', 'NULLNULL'),
(1, 'What does JVM stand for?', 'Java Virtual Machine', 'Java Visual Machine|Java Virtual Machine|Java Variable Machine|Java Version Manager', 'JVM is the Java Virtual Machine that enables Java programs to run on different platforms.', 'NULLNULL'),
(1, 'What is the result of the following expression?', 'Hello World', 'Hello World|Error|HelloWorld|"Hello" + " " + "World"', 'The expression concatenates "Hello" and "World" with a space in between.', 'assets/images/8.1.png'),
(1, 'Which of the following is used to handle exceptions in Java?', 'try-catch', 'catch|throw|try-catch|None of the above', 'The try-catch block is used to handle exceptions in Java.', 'NULLNULL'),
(1, 'Which of the following is a valid way to declare an array in Java?', 'int arr[] = new int[10];', 'int arr[] = new int[10];|int[] arr = new int(10);|int arr = new int[10];|int arr() = new int[10];', 'The valid syntax for declaring an array is int arr[] = new int[10];.', 'NULLNULL'),

-- Môn Kotlin
(2, 'Which of the following is the correct way to define a class in Kotlin?', 'class MyClass()', 'class MyClass|class MyClass()|MyClass()|class MyClass() : Any', 'In Kotlin, classes are declared using the "class" keyword followed by the class name.', 'NULLNULL'),
(2, 'Which operator is used to invoke a function in Kotlin?', '()', '[]|{}|()|->', 'In Kotlin, you use parentheses "()" to invoke a function.', 'NULLNULL'),
(2, 'What does the keyword "val" indicate in Kotlin?', 'A read-only variable', 'A read-only variable|A mutable variable|A function|A class', 'The "val" keyword in Kotlin declares a read-only (immutable) variable.', 'NULLNULL'),
(2, 'Which function is used to create a new instance of a class in Kotlin?', 'constructor()', 'new|newInstance|constructor()|init', 'In Kotlin, constructors are used to create instances of a class.', 'NULLNULL'),
(2, 'How do you handle null values in Kotlin?', 'By using nullable types', 'By using nullable types|By using "if" statements|By using exceptions|By ignoring them', 'Kotlin allows you to define nullable types by adding a "?" after the type name.', 'NULLNULL'),
(2, 'Which of the following is a valid way to declare a variable in Kotlin?', 'var x: Int = 10', 'var x: Int = 10|val x: Int = 10|var x = 10|val x = 10', 'Both var and val can be used to declare variables in Kotlin, with var for mutable and val for immutable variables.', 'NULLNULL'),
(2, 'What does the "companion object" keyword do in Kotlin?', 'It allows you to define static members', 'It allows you to define static members|It defines a singleton|It defines a nested class|It defines an interface', 'The "companion object" in Kotlin allows you to define static members within a class.', 'NULLNULL'),
(2, 'How do you define a data class in Kotlin?', 'data class Person(val name: String)', 'data class Person(val name: String)|class Person(val name: String)|data Person(val name: String)|Person(val name: String)', 'In Kotlin, a data class is defined with the "data" keyword followed by the class definition.', 'NULLNULL'),
(2, 'What is the correct way to define a lambda expression in Kotlin?', '{ x -> x * x }', '{ x -> x * x }|lambda {x: Int -> x * x}|{x -> x * x}|lambda (x: Int) -> x * x', 'A lambda expression in Kotlin uses curly braces with the input parameters and the function body inside.', 'NULLNULL'),
(2, 'What does the "in" keyword mean in Kotlin?', 'Used to define a range', 'Used to define a range|Used to define a function|Used to define a variable|Used to create a class', 'In Kotlin, the "in" keyword is used to define ranges, check membership, and for iteration.', 'NULL'),
-- Câu hỏi JavaScript
  (3, 'What does the typeof operator do in JavaScript?', 'Returns the type of a variable', 'Returns the type of a variable|Returns the value of a variable|Checks if a variable is defined|Converts a variable to a string', 'The typeof operator returns the type of the operand.', NULL),
  (3, 'Which of the following is the correct way to declare a variable in JavaScript?', 'All of the above', 'var x = 10;|x = 10;|let x = 10;|All of the above', 'All methods are valid for declaring variables in JavaScript.', NULL),
  (3, 'What does NaN represent in JavaScript?', 'Not a Number', 'Not a Number|Null and Not a Number|Not Available Number|None of the above', 'NaN stands for Not a Number.', NULL),
  (3, 'Which of the following is not a JavaScript primitive data type?', 'Object', 'String|Number|Object|Undefined', 'Object is not a primitive data type in JavaScript.', NULL),
  (3, 'What will the following code output?', '5', '5|6|Error|undefined', 'The post-increment operator returns the original value of x before incrementing.', 'assets/images/5.3.png'),
  (3, 'Which of the following is the correct syntax for adding an event listener to an element in JavaScript?', 'element.addEventListener(\'click\', function);', 'element.addEventListener(\'click\', function);|element.addEvent(\'click\', function);|element.add(\'click\', function);|None of the above', 'The correct syntax is element.addEventListener.', NULL),
  (3, 'What is the result of the following expression?', 'true', 'true|false|Error|undefined', 'In JavaScript, the double equals (==) operator performs type coercion, so 10 is equal to \'10\'.', 'assets/images/77.3.png'),
  (3, 'Which of the following is used to stop a loop in JavaScript?', 'break', 'stop|break|exit|end', 'The break statement is used to stop a loop in JavaScript.', NULL),
  (3, 'What does JSON stand for?', 'JavaScript Object Notation', 'JavaScript Online Notation|JavaScript Object Notation|JavaScript Oriented Notation|JavaScript Only Notation', 'JSON stands for JavaScript Object Notation.', NULL),
  (3, 'Which of the following methods is used to convert a string into an array in JavaScript?', 'split()', 'split()|join()|reverse()|slice()', 'The split() method is used to convert a string into an array based on a delimiter.', NULL);

COMMIT;