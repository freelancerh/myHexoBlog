---
title: Next Permutation [Leetcode#31]
date: 2015-05-11 12:01:22
tags: Leetcode
categories: Leetcode
photos: 
- http://7xlbns.com1.z0.glb.clouddn.com/%40%2Fhihuaning%2Fimage%2Fwz7.jpeg
---
<br/>

> 
Implement next permutation, which rearranges numbers into the lexicographically next greater permutation of numbers.If such arrangement is not possible, it must rearrange it as the lowest possible order (ie, sorted in ascending order).The replacement must be in-place, do not allocate extra memory.Here are some examples. Inputs are in the left-hand column and its corresponding outputs are in the right-hand column.
1,2,3 → 1,3,2
3,2,1 → 1,2,3
1,1,5 → 1,5,1

这个函数在c++的STL里有实现。之前在《算法竞赛入门经典》里接触过集合排列的问题，所以这次也没花多少时间就AC了这道题，需要注意的是此函数可以用在生成可重集的排列里。

### 下一个排列
---
##### 复杂度
时间 O(N) 空间 O(N)
##### 思路
从右到左找到第一个前一个比后一个数小的数，记其位置为p，比如12543，则2即是这个数，将p之后的数从小到大排列，然后从p+1开始找到第一个比在p位置的数大的数，然后交换它们的位置，这样就找到了下一个排列。
##### 代码
    public void nextPermutation(int[] nums) {
        if(nums==null || nums.length < 2)
			return;
        int i=nums.length-1;
        while(i>0 && nums[i] <= nums[i-1]){
        	i--;
        }
        //没找到需要交换的位置，将它变为从左到右的升序，因为已经从右到左是升序的，只要将它从中置换就可以转成从左到右的升序了。
        if(i < 1){
        	i = 0;
        	int j = nums.length-1;
        	while(i!=j && j+1!=i){
            	int temp = nums[i];
            	nums[i] = nums[j];
            	nums[j] = temp;
            	i++;
            	j--;
            }
        	return;
        }
        int place = i-1;
        int j = nums.length-1;
        //理由同上
        while(i!=j && j+1!=i){
        	int temp = nums[i];
        	nums[i] = nums[j];
        	nums[j] = temp;
        	i++;
        	j--;
        }
        for(i=place+1; i<nums.length; i++){
        	if(nums[i] > nums[place]){
        		int temp = nums[i];
        		nums[i] = nums[place];
        		nums[place] = temp;
        		break;
        	}
        }
    }