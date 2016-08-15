---
title: Permutations [leetcode]
date: 2015-05-27 12:01:22
tags: [Leetcode, 排列组合, 递归]
categories: Leetcode
photos: 
- http://7xlbns.com1.z0.glb.clouddn.com/%40%2Fhihuaning%2Fimage%2Flb%2Flb7.jpg
---

> Given a collection of **distinct** numbers, return all possible permutations.
For example,[1,2,3] have the following permutations:[1,2,3], [1,3,2], [2,1,3], [2,3,1], [3,1,2], and [3,2,1]

这道题之前在《算法竞赛入门经典》里看到过，题目相对简单，很容易想到用递归来求解。虽然这道题明确说明排列的值是不同的，但是如果排列的元素里有重复值怎么处理呢？上述书中也有这样的讨论，然而我觉得书里的解释有点不好理解。在下一篇文章里我将给出我的思路。

---
##### 复杂度
时间 O(nlogn) 空间 O(N)

##### 思路

利用递归求解，将需要排列的数加入已经排列的list里，并将刚刚加入的数从需要排列的list里删去，这样问题规模变成n-1了，递归结束条件是没有剩余的需要排列的数。

##### 代码
    public List<List<Integer>> permute(int[] nums) {
		List<List<Integer>> list = new ArrayList<List<Integer>>();
		List<Integer> tempList = new ArrayList<Integer>();
		List<Integer> numsList = new ArrayList<Integer>();
		for(int i=0; i<nums.length; i++){
			numsList.add(nums[i]);
		}
		findPermutations(list, tempList, numsList);
		return list;
    }
	
	public void findPermutations(List<List<Integer>> list, List<Integer> tempList, List<Integer> nums){
		if(nums.size() < 1){
			list.add(new ArrayList(tempList));
		}
		else{
			for(int i=0; i<nums.size(); i++){
				int temp = nums.remove(0);
				tempList.add(temp);
				findPermutations(list ,tempList, nums);
				tempList.remove((Object)temp);
				nums.add(temp);
			}
		}
	}