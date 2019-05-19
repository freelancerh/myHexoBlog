---
title: Search in Rotated Sorted Array [Leetcode]
date: 2015-05-14 12:01:22
tags: [Leetcode, 查找]
categories: Leetcode
photos: 
- /uploads/image/cover/lb1.jpeg
---
<br/>

>Suppose a sorted array is rotated at some pivot unknown to you beforehand.
(i.e., 0 1 2 4 5 6 7 might become 4 5 6 7 0 1 2).
You are given a target value to search. If found in the array return its index, otherwise return -1.You may assume no duplicate exists in the array.

这道题是二分搜索的一种变形。

---
##### 复杂度
时间 O(logn) 空间 O(N)
##### 思路
二分搜索的条件是数组必须是有序，而这道题里，通过随机的旋转将数组的后面一些部分转到前面了，形成了两个有序列，前面序列的最小元素大于后面序列的最大元素。题目同样可以用二分搜索的方法来解答，不过其中的一些条件改变了，找到mid，判断其nums[mid]是否大于或等于nums[low]，如果是的话，则mid在前一个序列里。这样序列就二分了，然后只要判断target是在mid之前还是在mid之后就行了。

##### 代码
    public int search(int[] nums, int target) {
        int low = 0;
        int high = nums.length-1;
        while(low <= high){
        	int mid = low + (high-low)/2;
        	if(nums[mid] == target){
        		return mid;
        	}
        	if(nums[mid] >= nums[low]){
        		if(nums[mid]>target && nums[low]<=target){
        			high = mid - 1;
        		}
        		else{
        			low = mid + 1;
        		}
        	}
        	else{
        		if(nums[mid]<target && nums[high]>=target){
        			low = mid + 1;
        		}
        		else{
        			high = mid-1;
        		}
        	}
        }
        return -1;
    }