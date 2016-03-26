> 1. design a whole UI, not single charts
> 2. problem statement specific
> 3. create data analysis questions using the domain language
> 4. create a concise but effective table for data abstraction

# What is the problem you want to sovle and who has this problem?
talk about:
1. background  
2. in what kind of situations our solution is needed  
3. what our dataset is about  
4. who has this problem and how do they benefit from our solution  

In this project, we focus on the tweets of NYC in realtime. 

# What questions do you want to be able to answer with you viz?

> What do you mean by questions is data analysis questions. It's questions about data and domain that you can answer when you use your visualization

be specific, not abstract
1. specific: find customers with similar behaviors
2. abstract: cluster of dataset coordinates according to their similarity

问题：
1. 如何发现当前热门话题？用最近数分钟内时间段按转发次数排序的列表（list）展示，排在越前面的就是越热门的话题。
2. 如何发现不同地区人们的兴趣差异？在地理地图上用颜色标记不同话题类型（category），颜色在不同地区的集聚差异表明了不同地区人们的差异。
3. 如何发现谁对话题变得热门贡献最大？用话题传播的网络，使用者可以选择将某个节点”关闭“，所有exclusive经过此点转发的路径均显示为未被传播。通过对比关闭节点前后话题的传播范围，可获知此用户在传播中的影响力。
4. 如何定位人们在热门话题的传播链所处的位置？
5. 具有相似兴趣的用户，是否在话题传播的位置也类似？

# details
## What is your data about?
## where does it come from?
## what attributes are you going to use?
## What is their meaning?
## What are their attribute types (data abstraction)?
## Do you plan to generate derived attributes? If yes, which and why?
至少有两个衍生数据：
1. class of topic
2. geolocation distict
3. 用户兴趣组

original:
| attribute name  | attribute type  | description | value range | derived |
| --------------- | --------------- | ----------- | ----------- | ------- |
| geolocation  | Categorical  | the location of tweets | -180~180, -90~90 | N |
| hashtags  | Categorical  | the content after "#" tag in tweets | N |
| created time | Ordinal | when did the tweets be posted |20160324 - present| N  |
| retweeted/quoted tweets (as links) | Categorical | ??? |
| mentions | Categorical | the users has been mentions("@") in tweets |  | N |
| favorite/retweet/quote count | Quantitative | the number of times of "favorite" and retweet/quote of tweets | N |
| lang | Categorical | the language used of tweets | N |
| text(as detail) | Categorical | the content of each tweets | N |

alternate:
| attribute name  | attribute type  | description | value range | derived |
| --------------- | --------------- | ----------- | ----------- | ------- |
| user | Categorical  | the author name of a tweet |  | N |
| geolocation  | Categorical  | the location name of tweets | -180~180, -90~90 | N |
| hot_issue  | Categorical  | the hot topics | Y |
| created time | Ordinal | when did the tweets be posted |20160324 - present| N |
| retweeted/quoted tweets count | Quantitative | times of retweeted/quote of a tweet | N |
| mentions | Categorical | the users has been mentions("@") in tweets |  | N |
| favorite count | Quantitative | times of "favorite" of a tweet | N |
| lang | Categorical | the language used of tweets | N |
| text | Categorical | the content of each tweets | N |


- geolocation => area
- retweets/quotes => rank of trend
- text => discount/promotes/etc.


# What have others done to solve this or related problems?
answer it form [here](https://interactive.twitter.com/)

The geography of Tweets[here](https://blog.twitter.com/2013/the-geography-of-tweets)
In this visualization, the author displayed the geography patterns that emerge from aggregated geo-taged Tweets over time among the world since 2009. In this pattern, the dots represents each Tweets and the color represents count. From it we can grasp much useful information easily. Such as Istanbul, Tokyo and New York are three cities with highest tweets density.

See the State of The Union address minute by minute on Twitter[here](http://twitter.github.io/interactive/sotu2015/#p1)
It explores the realtime reaction on Twitter of specific speech. The author displayed the volume of Tweets by using line. The subjects debated and where the tweets posted from across US also showed in right map. By clicking the spikes on the chart we can know related hot topics and which paragraphs are being talked.

# What solution do you propose? How does the solution help you answer the questions stated above?
TBD

# How do you plan to verify whether you have met your goals with this project?
- map: recognize distinguishable clusters
... 

# How is your project team going to work on the project? Who is going to do what?

- Yang Liu : Programming, Data/viz model design, UI design
- Jinglong Li: Analysis, UI design, Programming
- Yuan Zhou : Writing proposal, Data/viz model design, Programming
