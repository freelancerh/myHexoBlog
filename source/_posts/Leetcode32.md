---
title: Longest Valid Parentheses [Leetcode]
date: 2015-05-09 15:01:22
tags: [Leetcode,动态规划,Stack]
categories: Leetcode
photos: 
- /uploads/image/cover/wz6.jpg
---
<br/>
> Given a string containing just the characters '('and ')', find the length of the longest valid (well-formed) parentheses substring.For "(()", the longest valid parentheses substring is "()", which has length = 2.Another example is ")()())", where the longest valid parentheses substring is "()()", which has length = 4.

看完题目的第一反应就是用stack来处理，因为之前用stack来判断过括号是否匹配，按子串长度从n逐步减少到1的过程来查找，第一次找到的括号匹配子串即最长的子串，然而想想当问题规模很大而且又没有括号匹配子串时，它的时间复杂度是相当大的，故此方法舍之。

第二想法就是利用动态规划，自底向上来解这个问题。可以很容易地看出它的最优子结构，假设S是括号匹配的，则(S)，()S，S()，也是括号匹配的。用布尔型二维数组isValid[i][j]来表示i~j的串是否是匹配的，初始化isValid[i][i+1]，然后自底向上求解。这个方法上面的方法的复杂度好了很多，但是还是没有AC掉 TAT。

之后就是看了别人的解法才AC了这道题。



### 动态规划(个人解法)
---
#### 复杂度
时间 O(N^2) 空间 O(N^2)
#### 思路
如上
#### 代码

    public static int longestValidParentheses(String s) {
		if(s==null || s.length()<2){
			return 0;
		}
		int len = s.length();
        boolean[][] isValid = new boolean[len][len];
        int max = 0;
        /*初始化*/
        for(int i=0; i<len-1; i++){
        	if(s.charAt(i)=='(' && s.charAt(i+1)==')'){
        		isValid[i][i+1] = true;
        		max = 2;
        	}
        	else{
        		isValid[i][i+1] = false;
        	}
        }
        /*步长每次加2,*/
        for(int r=3; r<len; r+=2){
        	for(int i=0; i<len-r; i++){
                        /*最优子结构*/
        		if((isValid[i][i+r-2]&&s.charAt(i+r-1)=='('&&s.charAt(i+r)==')') || (isValid[i+1][i+r-1]&&s.charAt(i)=='('&&s.charAt(i+r)==')') || (isValid[i+2][i+r]&&s.charAt(i)=='('&&s.charAt(i+1)==')')){
        			isValid[i][i+r] = true;
        			max = r+1;
        		}
        		else{
        			isValid[i][i+r] = false;
        		}
        	}
        }
        return max;
    }

### 动态规划(别人家的解法)
---
#### 复杂度
时间 O(N) 空间 O(N)
#### 思路
动态规划法将大问题化为小问题，我们不一定要一下子计算出整个字符串中最长括号对，我们可以先从后向前，一点一点计算。假设d[i]是从<strong>下标i开始</strong>到字符串结尾最长括号对长度，s[i]是字符串下标为i的括号。如果s[i-1]是左括号，如果i + d[i] + 1是右括号的话，那d[i-1] = d[i] + 1。如果不是则为0。如果s[i-1]是右括号，因为不可能有右括号开头的括号对，所以d[i-1] = 0。
#### 代码

        public static int longestValidParentheses(String s){
		if(s==null || s.length()<2){
			return 0;
		}
		int len = s.length();
		int[] dp = new int[len];
		int max = 0;
		for(int i=0; i<len; i++){
			dp[i] = 0;
		}
		for(int i=len-2; i>-1; i--){
			if(s.charAt(i) == '('){
				int j=i+1+dp[i+1];
				if(j < len && s.charAt(j) == ')'){
					dp[i] = dp[i+1]+2;
					if(j+1 < len)
						dp[i] += dp[j];
					if(dp[i] > max){
						max = dp[i];
					}
				}
			}
		}
		return max;
	}

### 栈法 Stack(别人家的Stack解法)
---
#### 复杂度
时间 O(N) 空间 O(N)
#### 思路
用Stack的方法本质上和[Valid Parentheses](http://segmentfault.com/a/1190000003481208)是一样的，一个右括号能消去Stack顶上的一个左括号。不同的是，为了能够计算括号对的长度我们还需要记录括号们的下标。这样在弹出一个左括号后，我们可以根据当前坐标减去栈中上一个（也就是Pop过后的Top元素）的坐标来得到该有效括号对的长度。
#### 代码
     public class Solution {
      public int longestValidParentheses(String s) {
        Stack<Parenthese> stk = new Stack<Parenthese>();
        int maxLen = 0;
        for(int i = 0; i < s.length(); i++){
            //遇到左括号，将其push进栈
            if(s.charAt(i)=='('){
                stk.push(new Parenthese(i, '('));
            } else {
           //遇到右括号，分类讨论
               //如果当前栈顶是左括号，则消去并计算长度
                if(!stk.isEmpty() && stk.peek().symb=='('){
                    int curLen = 0;
                    stk.pop();
                    if(stk.isEmpty()){
                        curLen = i + 1;
                    } else {
                        curLen = i - stk.peek().indx;
                    }
                    maxLen = Math.max(maxLen, curLen);
                } else {
               //如果栈顶是右括号或者是空栈，则将右括号也push进栈，它的坐标将方便之后计算长度
                    stk.push(new Parenthese(i, ')'));
                }
            }
        }
        return maxLen;
    }
    
    public class Parenthese {
        int indx;
        char symb;
        public Parenthese (int i, char s){
            this.indx = i;
            this.symb = s;
        }
    }

----
### 参考资料
[Longest Valid Parentheses](https://segmentfault.com/a/1190000003481194)