#!/usr/bin/env python
# coding: utf-8

# In[14]:


#Import the required libraries
import pandas as pd
import numpy as np
import seaborn as sns

import matplotlib.pyplot as plt
import matplotlib.mlab as mlab
import matplotlib
plt.style.use('ggplot')
from matplotlib.pyplot import figure

get_ipython().run_line_magic('matplotlib', 'inline')
matplotlib.rcParams['figure.figsize'] = (12,8)

pd.options.mode.chained_assignment = None



# Now we need to read in the data
df = pd.read_csv(r'E:\shivam\portfolio\python\movies.csv')


# In[15]:


# Peek at the data
df


# In[16]:


# Different ways of dropping values with NaN

# df.dropna(how='all')     #drop only if ALL columns are NaN
# df.dropna(thresh=2)   #Drop row if it does not have at least two values that are **not** NaN
# df.dropna(subset=[1])   #Drop only if NaN in specific column 


df.dropna()




# In[17]:


# Check if there's any missing value

for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print('{} - {}%'.format(col, round(pct_missing*100)))


# In[18]:


# Data Types for columns

print(df.dtypes)


# In[ ]:





# In[19]:


# Dropping any duplicate in the data
df.drop_duplicates()


# In[11]:





# In[20]:


# Sorting Data 

df.sort_values(by=['gross'], inplace=False, ascending=False)


# In[ ]:





# In[22]:


# Scatter Plot : Budget vs Gross

plt.scatter(df.budget, df.gross, color = 'yellow')
plt.title('Budget vs Gross Earnings')
plt.xlabel('Gross Earnings')
plt.ylabel('Budget Earnings')


# In[ ]:





# In[25]:


#Scatter Plot using Seaborn

sns.regplot(x='budget', y='gross', data=df, scatter_kws=  {'color' :'yellow'}, line_kws={'color':'red'})


# In[ ]:





# In[26]:


#Correlation between different features of dataset
df.corr()


# In[28]:


plt.figure(figsize=(16,8))
sns.heatmap(df.corr() , annot=True, fmt = '.2f')
plt.title ('Correlation Matrix')
plt.xlabel('Movies features')
plt.ylabel('Movies features')


# In[ ]:





# In[29]:


# Converting Categorical Columns to integers
converted_df = df 


# In[31]:



for col in converted_df.columns:
    if(converted_df[col].dtype == 'object'):
        converted_df[col] = converted_df[col].astype('category')
        converted_df[col] = converted_df[col].cat.codes


# In[32]:


converted_df


# In[ ]:





# In[33]:


plt.figure(figsize=(14,7))
sns.heatmap(converted_df.corr(), annot=True, fmt='.2f')
plt.title('Correlation Matrix')
plt.xlabel('Movies features')
plt.ylabel('Movies features')


# In[34]:


#Highest correlation

converted_df_corr = converted_df.corr()['gross']
converted_df_corr


# In[35]:


converted_df_corr[(converted_df_corr>0.5) & (converted_df_corr.index != 'gross')].sort_values(ascending=False)


# In[39]:


'''Therefore, we can conclude that there is high correlation between Gross Revenue and Budget and, then Votes.'''


# In[ ]:




