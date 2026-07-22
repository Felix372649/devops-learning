小提示：
prompt mysql [\d]>
执行完这行命令后，只要你使用 use 切换数据库，你的命令行就会变成类似这样：
mysql [game]>
这样你就能永远直观地看到自己目前在哪个库里了。
==================================
创建数据库名：
create database game_mysql；

查看数据库：
show databases;

进入数据库：
use game_mysql;

创建表格：
create table game (id int , name varchar(20) , game varchar(40));

查看表格目录：
desc game;


==========================
修改表格目录内容：
      我还想添加每个选手的年龄（age），我该怎么办？
alter table game add age varchar (10);



改表格顺序：
       想把age放在name后面
alter table game modify age varchar(10) after name;
( alter修改， 和after将其放置在字段之后， 还有modify要修改的 )




插入表格写入Luck选手数据：
insert into game (id , name , age , game) values ("0472" , "Luck" , "32" , "CSGO");

写入LaTo大神数据：
insert into game (id , name , age , game) values ("0472" , "LaTo" , "34" "SanJiaoZhouXingDong");

查看表格内容信息：
select * from game；



修改表格目录内容：
添加游戏类型(genre)
alter table game add genre varchar(10);



修改Luck 添加genre数据：
update game set genre = 'FPS' where name = 'Luck' limit 1;



插入3条新数据用于测试练习
insert into game (id, name, age, game, genre) values ("0474", "guoguo", 28, "LOL", "MOBA");
insert into game (id, name, age, game, genre) values ("0475", "yunhai", 27, "CS2", "FPS");
insert into game (id, name, age, game, genre) values ("0476", "lao8", 35, "DOTA2", "MOBA");

-- 查看现在的所有数据，确认数据已丰满
select * from game;
==============================================================================
练习复杂查询 (Advanced SELECT)
现在表里有5个人了，可以验证英语指令的筛选和排序逻辑。

1. 条件查询 (WHERE = 在哪里/当什么条件时)
找出所有年龄大于30岁的选手
select * from game where age > 30;

2. 指定列查询 
实际工作中表可能有一百列，只看特定的列能提高性能
select name, game from game;

3. 排序查询 (ORDER BY = 按照...排序, DESC = 降序/从大到小)
看看谁年纪最大
select * from game order by age desc;



练习表结构修改 (ALTER / RENAME)
随着业务发展，表格的名字或列名往往需要调整。

1. 重命名字段 (CHANGE = 改变)
之前列名叫 game，表名也叫 game，很容易混淆。把列名 game 改成 game_name。
alter table game change game game_name varchar(40);

查看一下表结构，确认是否改名成功
desc game;

修改表名 (RENAME TO = 重命名为)
将整个表的名称从 game 改为更专业的 esports_players
rename table game to esports_players;

此时如果执行 select * from game; 会报错，必须用新表名
select * from esports_players;


练习约束条件 (Constraints)
在现有的表上追加规则，防止录入垃圾数据。

1. 默认值 (DEFAULT = 默认)
-- 设置 genre 列的默认值为 '未分类'。以后如果不填游戏类型，系统会自动补上这个词。
alter table esports_players alter genre set default '未分类';

2. 非空约束 (NOT NULL = 不能为空)
强制要求录入数据时，选手名字必须填，不能留空。
alter table esports_players modify name varchar(20) not null;
第五步：练习删除与清空 (DELETE / DROP)
注意：这是破坏性操作，必须放在最后练。 按照破坏程度从低到高进行：

练习删除与清空 (DELETE / DROP)
(注意：这是破坏性操作，必须放在最后练。 按照破坏程度从低到高进行)

1. 删除特定数据行 (DELETE = 删除数据)
业务逻辑：LaTo退役了，从数据库中删掉他。
delete from esports_players where name = 'LaTo';

2. 删除表中的某一个字段 (DROP COLUMN = 扔掉列)
业务逻辑：不需要区分游戏类型(genre)了，把这列干掉。
alter table esports_players drop column genre;

3. 清空整个表的数据，但保留表的“空壳” (TRUNCATE = 截断/清空)
业务逻辑：所有选手数据作废，但表结构留着以后重新录入。
truncate table esports_players;

4. 彻底删除表 (DROP TABLE = 连根拔起)
业务逻辑：这个项目黄了，表彻底不要了。
drop table esports_players;

==============================================================================

一、 核心动作指令（动词）
CREATE 创建           从无到有建立新东西（建库、建表）
DROP 摧毁 / 丢弃      连根拔起，彻底删除（删库、删表）
ALTER 改造            修改结构，修修补补（加列、删列、改列名）
SELECT 查询 / 挑选    拿出来看看（查数据）
INSERT 插入 / 新增    往表里录入新的数据行
UPDATE 更新           修改表里已有的数据内容
DELETE 删除           删除表里的某些数据行（保留表结构）
TRUNCATE 清空 / 截断  瞬间清空表内所有数据

二、 核心对象（名词）
DATABASE 数据库       最大的容器
TABLE 表              数据库里的二维表格
COLUMN 列 / 字段      表格的竖列（如：age, name）
ROW 行 / 记录         表格的横行（具体的一条数据）
VIEW 视图             虚拟的表（查数据常用）
INDEX 索引            数据库的“目录”（优化查询速度的核心）

三、 必备介词与连接词（连词）
FROM 从...（哪里）    配合SELECT使用（从哪个表查）
INTO 进入...          配合INSERT使用（插入到哪个表）
VALUES 值             具体要插入的数据内容
SET 设置              配合UPDATE使用（设置成什么新值）
WHERE 当...（条件）   精确定位，满足什么条件才操作
AND 并且              交集（同时满足多个条件）
OR 或者               并集（满足其中一个条件即可）
TO 到 / 变成          配合RENAME使用（改名成什么）

四、 结构修饰与约束（规则）
PRIMARY 主要的        常与KEY连用，代表主键（唯一标识）
KEY 键 / 钥匙         同上
DEFAULT 默认          如果不填，系统默认给什么值
NULL 空值             代表什么都没有（NOT NULL代表不能为空）
MODIFY 修改           ALTER的小弟，专用于修改列的数据类型
CHANGE 改变           ALTER的小弟，专用于重命名列
RENAME 重命名         改表名
ORDER 排序            常与BY连用，按照什么排序
BY 按照               同上
DESC 降序             从大到小排
ASC 升序              从小到大排（默认，常省略）
LIMIT 限制            限制操作或显示的条数（防误操作全表）

