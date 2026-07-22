#====================[ 字 典 dict ]=======================
# 通过【字 / 词语】，找到该字对应的【解释】。
# 每个【字 / 词语】对应一个解释，【字 / 词语】是不能重复的。
# Python 中的字典（dict），里面存储的是键值对（key：value）类型的数据，可以根据键 (key) 找到对应的值 (value)。

# 为什么要使用字典呢？
# 现需要存储班级学员高考成绩，其中包含 王林 (670)，韩立 (556)，李慕婉 (582)，紫灵 (435)，许立国 (608)...
# 该如何存储呢？

# 不用字典的情况下！进行数据存储需要用列表来做

# 定义列表存储：
# name_list  = ["王林", "韩立",  "李慕婉", "紫灵", "许立国", "王政", "张紫"]
# score_l1st = [670,     556,    582,     435,    608,     512,    678]
# 缺点：用列表会非常繁琐！低效！必须保证俩列表索引里名字和成绩 必须都能对上！


# 定义字典存储：
# 字典：使用键值对（key：value）来存储数据，每一个键都对应一个值，通过键（key）可以快速找到对应的值（value）。
# 特点：键值对（key：value）存储、键（key）不能重复、可修改。

# 字典定义   key : value   key : value      key : value     key : value
# dict1 = {"王林": 670,  "韩立": 556,    "李慕婉": 582,    "紫灵": 435,     "许立国": 608, "王政": 522, "张彪": 578}

# print(dict1["王林"])      # 这样就能查到 王林 的成绩！

# 定义空字典的方式：
# 字典名称 = {}
# dict1   = {}
# dict2   = dict()

# 根据key获取value:
# 值 = 字典名称[key]


# 注意：字典(dict)中的value可以是任何类型的数据，而key不能为可变类型 (如：不能为列表list、集合set、字典dict)，

# dict1 = {"王林": 670} # 说人话：670成绩可以任意改！但是名字（key）：不能用 list/set/dict 做 key；想“改名”只能删除重建！


#====================[ 字 典 dict 基 本 操 作 ]=======================
# key必须得是不可变类型（str、int、float、tuple）
# dict_666 = {"王林":820, "Luck":608, "Felix":580,"Luck":10000000000000000000000}
# # print(dict_666)
# print(dict_666["Luck"])                 # key值是不能重复的，否则后面的会覆盖前面的值！
                                          # 解决方式：删掉重复的！


# dict2= {0:820, 1.5:608, (1,2):580,}     # float小数是可以做key的
#dict3= {0:820, 1.5:608, ["a","b"]:580,}  # 列表list ["a","b"] 就不能做key，因为是可变的！


# ------「如何访问字典中的数据？」------
# print(dict_666["王林"])    # 获取字典中的值
# print(dict2[0])           # 获取字典中的值
#
# dict2[0] = 100            # 更改对应的值
# print(dict2[0])


# ======「总结字典的注意事项」======
# value 可以是任意类型，而 key 必须是不可变类型（不能为 list、set、dict）
# 字典内的 key 不允许重复，如果重复定义，后面的覆盖前面的
# 字典是没有索引下标的，不能根据索引获取值，只可以根据 key 获取 value



#===========================[字 典 dict 常 用 操 作 ]==============================
# 类型	操作	                        含义	                                   样例

# 添加	字典名称[key] = value	  往指定字典中添加key-value 键值对	             dict1["涛哥"] = 688
# 删除	字典名称.pop(key)	      删除字典中指定的key,并返回该key对应的value	   score = dict1.pop("涛哥")
# 删除	del 字典名称[key]	      删除字典中指定的键值对	                       del dict1["涛哥"]
# 修改	字典名称[key] = value	  修改字典中指定的key对应的值                   dict1["小智"] = 658
# 查询	字典名称[key]	          根据 key 获取 value	                       dict1["涛哥"]
# 查询	字典名称.get(key)	      根据 key 获取 value	                       dict1.get("涛哥")
# 查询	字典名称.keys()	        获取所有的 key	                             dict1.keys()
# 查询	字典名称.values()	      获取所有的 value	                           dict1.values()
# 查询	字典名称.items()	        获取所有的 key-value 键值对	                 dict1.items()



# dict1 = {"王一":623,"王三":980}
# print(dict1)
#
# #------[ 添加 key 不存在就是添加 ]------
# dict1["王二"]= 325
# print(dict1)
#
# #------[ 修改 key 存在就是修改 ]------
# dict1["王二"]= 666
# print(dict1)
#
# #------[ 查 询 ]------
# print(f"根据key查值:{dict1["王二"]}")         # 根据key查值
# print(f"根据key查值:{dict1.get("王二")}")     # 根据key查值
#
# print(dict1.keys())                          # 查所有的key
# print(dict1.values())                        # 查所有的值
# print(dict1.items())                         # 获取所有的键值对,key:values
#                                              # 里面是一个个元组包裹的键值对
#
# #------[ 删 除 ]------
# score =dict1.pop("王三")                      # 返回的值！删除的值写进score里！
# print(dict1.items())
# print(score)
#
# del dict1["王一"]                             # del 只执行删除动作，没有任何返回值，删完就结束，不能用变量接收结果。
# print(dict1)


#------[ 遍 历 ]------
# dict_666 = {"王林":820, "Luck":608, "Felix":580,}
# for k in dict_666.keys():                       # 将字典里key(就是显示名字！)一个一个写入k变量里！
#     print(f"key是：{k}\t值是：{dict_666[k]}")    # 这样知道了key就能查key里面的值，所以dict_666[k],一轮一轮一个一个打印出字典的values值
#
# for i in dict_666.items():                      # items()是直接显示key和values值，写入i变量里！
#     print(f"key:{i[0]}\tvalues:{i[1]}")         # 这样i的0号索引就是key  1号索引就是values值
#
# for l,o in dict_666.items():                    # 用解包的方式把第一个元素key写入l里，把第二个元素values写入o里
#     print(f"key是:{l}\t值是{o}")                 # 直接打印l和o就完事了！

#======[ 总 结 ]======
# 1. 字典的常用操作？
# 添加：字典[key] = value （key 不存在，就会执行新增）
# 删除：del 字典[key] / value = 字典.pop(key)
# 修改：字典[key] = value （key 存在，就会执行修改）
# 查询：字典[key] / 字典.get(key)；字典.keys() / 字典.values() / 字典.items()

# 2. 字典的遍历？
# 字典支持 for 循环遍历
# 通过keys()、values()、items() 进行循环遍历
