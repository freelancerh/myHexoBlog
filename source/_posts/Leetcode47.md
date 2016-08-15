---
title: Permutations II [leetcode]
date: 2015-05-28 12:01:22
tags: [Leetcode, 排列组合, 递归]
categories: Leetcode
photos: 
- http://7xlbns.com1.z0.glb.clouddn.com/%40%2Fhihuaning%2Fimage%2Flb%2Flb8.jpg
---

> Given a collection of numbers that might contain duplicates, return all possible unique permutations.
For example,[1,1,2] have the following unique permutations:[1,1,2], [1,2,1], and [2,1,1]

前一篇文章讲了无重复元素的排列，这篇文章讲的是有重复元素的排列问题怎么解决。

---
##### 复杂度
时间 O(nlogn) 空间 O(N)

##### 思路

在无重复元素排列的基础上，我们只需要在每次进入递归前判断当前元素是否在之前已经排列过，这样我们刚开始就需要将待排列的数组排序以便于判断。

##### 代码

    public List<List<Integer>> permuteUnique(int[] nums) {
        Arrays.sort(nums);
        List<List<Integer>> list = new LinkedList<List<Integer>>();
        List<Integer> tempList = new ArrayList<Integer>();
        List<Integer> numsList = new ArrayList<Integer>();
        for(int i : nums){
        	numsList.add(i);
        }
        find(list, numsList, tempList);
        return list;
    }
	public void find(List<List<Integer>> list, List<Integer> numsList, List<Integer> tempList){
		if(numsList.isEmpty()){
			list.add(new ArrayList(tempList));
		}
		else{
			for(int i=0; i<numsList.size(); i++){
				if(i==0 || numsList.get(i) != numsList.get(i-1)){
					int temp = numsList.get(i);
					tempList.add(temp);
					numsList.remove(i);
					find(list, numsList, tempList);
					tempList.remove(tempList.size()-1);
					numsList.add(i, temp);
				}
			}
		}
	}