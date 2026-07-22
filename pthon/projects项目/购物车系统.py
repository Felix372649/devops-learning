#======[开发一个购物车管理系统，实现商品信息的添加、修改、删除、查询功能。系统使用字典结构存储商品数据，通过控制台菜单与用户交互]======
# 1.添加购物车：用户根据提示录入商品名称、以及该商品的价格、数量，保存该商品信息到购物车。
# 2.修改购物车：要求用户输入要修改的购物车商品名称，然后再提示输入该商品的价格、数量，输入完成后修改该商品信息。
# 3.删除购物车：要求用户输入要删除的购物车名称，根据名称删除购物车中的商品。
# 4.查询购物车：将购物车中的商品信息展示出来，格式为："商品名称：xxx，商品价格：xxx，商品数量：xxx"。
# 5.退出购物车

shopping_cart={}
print("""
#### 购物车系统 ####
#   1.添加购物车   #
#   2.修改购物车   #
#   3.删除购物车   #
#   4.查询购物车   #
#   5.退出购物车   #
###################""")

while True:
    aa=int(input("请输入要执行的操作(1-5):"))
    match aa:
        case 1:
        # 1.添加购物车：用户根据提示录入商品名称、以及该商品的价格、数量，保存该商品信息到购物车。
            goods_name=input("请输入商品名：")
            goods_price=float(input("请输入商品价格："))
            goods_num=int(input("请输入商品数量："))
            shopping_cart[goods_name]={"price":goods_price,"num":goods_num}

        case 2:
        # 2.修改购物车：要求用户输入要修改的购物车商品名称，然后再提示输入该商品的价格、数量，输入完成后修改该商品信息。

            goods_name = input("请输入商品名：")
            if goods_name not in shopping_cart:
                print("此商品不在购物车中")
                continue
            goods_price = float(input("请输入商品价格："))
            goods_num = int(input("请输入商品数量："))
            shopping_cart[goods_name]={"price":goods_price,"num":goods_num}
            print("已修改该商品信息")

        case 3:
            goods_name = input("请输入商品名：")
            if goods_name not in shopping_cart:
                print("此商品不在购物车中")
                continue
            del shopping_cart[goods_name]

        case 4:
            for i in shopping_cart:
              # 循环多轮，每一轮把字典的key值 就是商品名称 写进了i变量里
                print(f"商品:{i}\t价格:{shopping_cart[i]["price"]}\t数量:{shopping_cart[i]["num"]}")
                # 字典shopping_cart 加[i]商品名称 加["price"]values值 直接打印除商品的价格。数量和价格打印方法一样！
                # 就这样一轮一轮把购物车里的商品挨个打印出来！
  
                #------[更精简写法]------
                # for name,info in shopping_cart.items():
                #   print(f"商品：{name}\t价格：{info['price']}\t数量：{info['num']}")

                # .items() 的核心机制叫解包（unpacking），它只负责把字典最外层的“键”和“值”拆成两半。
                # 在每轮循环时，items() 扔出来的是这样一对组合：第一轮("苹果", {"price": 5, "num": 10})  第二轮("香蕉", {"price": 10, "num": 3})
                # 循环每轮 把  "苹果" 和 {"price": 5, "num": 10} 分为两个部分分别写进name 和info 变量里
                # 左边的键（"苹果"）被赋给了第一个变量 name 里
                # 右边的值（整个内层字典 {"price": 5, "num": 10}）被赋给了第二个变量 info

        case 5:
            break

        case _:
            print("输入错误，请重新输入")


