# PySpark notes

### Transformation functions
```pyspark
filter(func) # returns a new DataFrame formed by selecting those rows of the source on which func returns true
where(func) # where is an alias for filter
distinct() # return a new DataFrame that contains the distinct rows of the source DataFrame
orderBy(*cols, **kw) # returns a new DataFrame sorted by the specified column(s) and in the sort order specified by kw
sort(*cols, **kw) # Like orderBy, sort returns a new DataFrame sorted by the specified column(s) and in the sort order specified by kw
explode(col) #returns a new row for each element in the given array or map
map()
flatMap()
mapPartitionns()
intersection()
zipWihIndex()
pipe()
coalesce()
```


##### Using transformation use
```pyspark
df = sqlContext.createDataFrame(data, ['name', 'age'])
from pyspark.sql.types import IntegerType
doubled = udf(lambda s: s * 2, IntegerType())
df2 = df.select(df.name, doubled(df.age).alias('age'))
df3 = df2.filter(df2.age > 3)
```


##### GroupedData Transformations
```pyspark
groupBy(*cols) groups the DataFrame using the specified columns, so we can run aggregation on them
groupByKey()
reduceByKey()
agg(*exprs) Compute aggregates (avg, max, min, sum, or count) and returns the result as a DataFrame
count() counts the number of records for each group
avg(*args) computes average values for numeric columns for each group
```

Using grouped data
```bash
df1 = df.groupBy(df.name)
df1.agg({"*": "count"}).collect()
df.groupBy(df.name).count() #same as 2 lines above
df.groupBy().avg().collect()
df.groupBy('name').avg('age', 'grade').collect()
```


### Actions
```bash
show(n, truncate) # prints the first n rows of the DataFrame
take(n) # returns the first n rows as a list of Row
takeOrdered()
collect() # return all the records as a list of Row --> WARNING: make sure will fit in driver program
count()  # returns the number of rows in this DataFrame
describe(*cols) # Exploratory Data Analysis function that computes statistics for numeric columns
reduce()
first()
saveAsTextFile()
```

##### Using actions
```bash
df = sqlContext.createDataFrame(data, ['name', 'age'])
df.collect()
```

### Spark lifecycle
```bash
linesDF = sqlContext.read.text('...')  # 1. Create DataFrames from external data or createDataFrame from a collection in driver program
linesDF.cache() # save, don't recompute! # 2. Lazily transform them into new DataFrames
commentsDF = linesDF.filter(isComment) # 3. cache() some DataFrames for reuse
print linesDF.count(), commentsDF.count() # 4. Perform actions to execute parallel computation and produce results
```
### Spark sql
```bash
df.join(df2, 'name') # inner as default
df.join(df2, 'name').select(df.name, df2.height)
df.join(df2, 'name', 'outer') # left_outer, right_outer
```


### Create RDD (Resiliant Distributed Dataset)
##### Parallelize in Python
```bash
# Take an existing inmemory collection and pass it to SparkContext’s parallelize method
wordsRDD = sc.parallelize(["fish", "cats", "dogs"]) 
```

### Read a local txt file in Python
```bash
# Other methods to read data from HDFS, C*, S3, HBase, etc
linesRDD = sc.textFile("/path/to/README.md") 
```

