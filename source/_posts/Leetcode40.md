---
title: Combination Sum II [Leetcode]
date: 2015-05-22 12:01:22
tags: [Leetcode, 排列组合, 递归]
categories: Leetcode
photos: 
- /uploads/image/cover/lb6.jpg
---

>Given a collection of candidate numbers (***C***) and a target number (***T***), find all unique combinations in ***C*** where the candidate numbers sums to ***T***.
Each number in ***C*** may only be used **once** in the combination.
**Note:**
All numbers (including target) will be positive integers.
Elements in a combination (*a*1, *a*2, … , *a*k) must be in non-descending order. (ie, *a*1≤ *a*2≤ … ≤ *a*k).
The solution set must not contain duplicate combinations.
For example, given candidate set 10,1,2,7,6,1,5 and target 8, A solution set is: [1, 7]
 [1, 2, 5]
 [2, 6]
 [1, 1, 6]
 
这道题很明显可以采用递归来进行求解。

---
##### 复杂度
时间 O(nlogn) 空间 O(N)
##### 思路
先将数组进行排序，然后利用递归函数来将问题规模缩小，当target等于0的时候将组合的数放入list中，要注意的是每次判断能否进入下个递归之前，先要判断这个数是否在这个递归层级里用过。

##### 代码

    public List<List<Integer>> combinationSum2(int[] candidates, int target) {
		Arrays.sort(candidates);
		List<List<Integer>> list = new ArrayList<List<Integer>>();
		List<Integer> container = new ArrayList<Integer>();
		combination(candidates, target, list, container, 0);
		return list;
    }
	
	void combination(int[] candidates, int target, List<List<Integer>> list, List<Integer> container, int start){
		if(target == 0){
			list.add(new ArrayList<Integer>(container));
		}
		else{
			for(int i=start; i<candidates.length; i++){
				if(i==start || candidates[i]!=candidates[i-1]){
					if(target-candidates[i] >= 0){
						container.add(candidates[i]);
						combination(candidates, target-candidates[i], list, container, i+1);
						container.remove(container.indexOf(candidates[i]));
					}
					else{
						break;
					}
				}
				
			}
		}
	}