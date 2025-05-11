#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd

# Load dataset (assumes you have the CSV downloaded)
df = pd.read_csv('StudentsPerformance.csv')
df


# In[2]:


from scipy.stats import ttest_ind

# Split into two groups
group_completed = df[df['test preparation course'] == 'completed']['math score']
group_none = df[df['test preparation course'] == 'none']['math score']

# Perform t-test
t_stat, p_val = ttest_ind(group_completed, group_none)

t_stat, p_val


# In[3]:


print(f"T-statistic: {t_stat:.3f}, P-value: {p_val:.3f}")


# In[4]:


from scipy.stats import shapiro, levene

print("Shapiro Test - Completed:", shapiro(group_completed))
print("Shapiro Test - None:", shapiro(group_none))
print("Levene’s Test for equal variances:", levene(group_completed, group_none))


# ## for understanding
# ### shapiro-Wilk Test (shapiro):
# Used to check if the data is normally distributed (i.e., bell-shaped curve).
# 
# Why? Because a t-test assumes normality in the distribution of the two groups.
# 
# Each call here checks normality of math scores for:
# 
# Students who completed the test prep
# 
# Students who did not complete the test prep
# 
# | Test        | Purpose                  | Assumption Tested                      | p-value Meaning   |
# | ----------- | ------------------------ | -------------------------------------- | ----------------- |
# | `shapiro()` | Normality                | Data should be normally distributed    | p > 0.05 → Normal |
# | `levene()`  | Homogeneity of variances | Both groups should have equal variance | p > 0.05 → Equal  |
# 

# In[5]:


if p_val < 0.05:
    print("Reject the null hypothesis: Prep course significantly affects math scores.")
else:
    print("Fail to reject the null: No significant difference in math scores.")


# In[6]:


# Compute correlation matrix
correlation_matrix = df[['math score', 'reading score', 'writing score']].corr()
correlation_matrix


# In[7]:


import seaborn as sns
import matplotlib.pyplot as plt

plt.figure(figsize=(6, 4))
sns.heatmap(correlation_matrix, annot=True, cmap='coolwarm', fmt=".2f")
plt.title("Correlation Matrix of Scores")
plt.show()


# In[8]:


# Find strongest positive correlation (excluding self-correlation)
corr_pairs = correlation_matrix.unstack()
strongest_corr = corr_pairs[corr_pairs != 1.0].sort_values(ascending=False).head(1)
strongest_corr


# corr_pairs != 1.0: Removes self-correlations (e.g., math with math = 1.0)
# 
# .sort_values(ascending=False): Sorts the remaining pairs by correlation strength (highest first)
# 
# .head(1): Picks the strongest positive correlation (top one)
# 
# 

# In[9]:


import statsmodels.formula.api as smf

# Encode categorical variable
df['test_prep_encoded'] = df['test preparation course'].map({'none': 0, 'completed': 1})

# Fit the model
model = smf.ols('Q("math score") ~ Q("reading score") + test_prep_encoded', data=df).fit()

# Show model summary
print(model.summary())


# ## Interpret the meaning of at least one predictor coefficient in context:
# reading score:
# Holding test preparation constant, students with higher reading scores tend to also have higher math scores. Specifically, each additional point in reading score is associated with a 0.85-point increase in math score on average, and this relationship is highly statistically significant (p < 0.001).

# The R-squared value is 0.669, which means that about 66.9% of the changes in math scores can be explained by reading scores and whether the student took the test preparation course. 
# 
# Also, the F-statistic is 1007 and the p-value is very small (less than 0.001). This tells us that the model is statistically significant.

# | Test / Metric             | Result     | Interpretation                                                                   |
# | ------------------------- | ---------- | -------------------------------------------------------------------------------- |
# | **Durbin-Watson = 2.079** | Near 2     | Residuals are likely independent                                        |
# | **Omnibus & JB p-values** | > 0.05     | Residuals are **not significantly non-normal** → normality assumption is **met** |
# | **Skew / Kurtosis**       | Near 0 & 3 | Acceptable values                                                            |
# 

# In[10]:


# Residual plot
import matplotlib.pyplot as plt

plt.scatter(model.fittedvalues, model.resid)
plt.axhline(0, color='red', linestyle='--')
plt.xlabel("Fitted Values")
plt.ylabel("Residuals")
plt.title("Residual Plot")
plt.show()

# Histogram of residuals
plt.hist(model.resid, bins=30, edgecolor='k')
plt.title("Histogram of Residuals")
plt.xlabel("Residual")
plt.ylabel("Frequency")
plt.show()


# In[ ]:




