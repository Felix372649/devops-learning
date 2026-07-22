#!/bin/bash
b9(){
echo "不再想了，辞职！"
}

a(){
echo "你肯定？"
read -p "请输入yes 或 no" a
case $a in
        yes)
        b9
        ;;
        no)
        b1
        ;;
	*)
	;;
        esac
}


b1(){
echo "找到新工作了吗？(yes/no)"
read -p "请输入：" b1
case $b1 in
        yes)
        a1
        ;;
        no)
        c3
        ;;
        esac
}

b2(){
echo "跟老板谈一下"
echo "谈得怎样？1.不要提了 2.还好"
read -p "请输入：" b2
case $b2 in
        1)
        b1
        ;;
        2)
        b3
        ;;
        esac
}

b3(){
echo "还要辞职吗？"
read -p "请输入：" b3
case $b3 in
        yes)
        a7
        ;;
        no)
        b8
        ;;
        esac
}

a1(){
echo "真的想做？"
read -p "请输入：" a1
case $a1 in
        yes)
        a7
        ;;
        no)
        b1
        ;;
        esac
}

a7(){
echo "辞职了会后悔吗？" 
read -p "请输入：" a7
case $a7 in
        yes)
        b8
        ;;
        no)
        b9
        ;;
        esac
}

b8(){
echo "再做几个月看看？"
read -p "请输入：" b8
case $b8 in
        yes)
        c8
        ;;
        no)
        b9
        ;;
        esac
}

c7(){
echo "那为何又再绕到这里呢?(输入yes)"
read -p "" c7
case $c7 in
        yes)
	c3
        ;;
        esac
}

c8(){
echo "做的怎样？(yes还好/no不好)" 
read -p "请输入：" c8
case $c8 in
        yes)
        c7
        ;;
        no)
        b3
        ;;
        esac
}


c1(){
echo "有没有人养你下半生？" 
read -p "请输入：" c1
case $c1 in
        yes)
        c2
        ;;
        no)
        b1
        ;;
        esac
}

c2(){
echo "信得过？"
read -p "请输入：" c2
case $c2 in
        yes)
        b9
        ;;
        no)
        b1
        ;;
        esac
}

c3(){
echo "老实说，为什么想辞职？"
echo "1.人工不够高"
echo "2.做的不开心"
echo "3.纯粹想走"
echo "4.追梦想"
read -p "请输入" c3
case $c3 in
	1)
	b2
	;;
	2)
	b2
	;;
	3)
	b9
	;;
	4)
	c4
	;;
	esac
}

c4(){
echo "一定要辞职才能追到？"
read -p "请输入：" c4
case $c4 in
        yes)
        b9
        ;;
        no)
        b8
        ;;
        esac
}


#===================================================
echo "你有没有足够的资金维持自己下半生的生活？"
echo "输入 yes 或 no"
read -p "请输入：" b
case $b in
	yes)
	a
	;;
	no)
	c1
	;;
	*)
	echo "输入错误，请重新输入 yes 或 no"
	# 这里可以再次调用当前函数进行重试
	;;
esac
