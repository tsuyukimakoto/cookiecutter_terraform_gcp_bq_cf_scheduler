import os
from google.cloud import bigquery
import functions_framework

client = bigquery.Client()

dataset_id = os.environ.get("DATASET_ID")
query = f"""WITH predata as (
select
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'ga_session_id') as session_id,
    (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_title') as page_title,
    (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') as page
from
    `{dataset_id}.events_*`
where
  _table_suffix between format_date('%Y%m%d', date_sub(current_date(), interval 8 day)) and format_date('%Y%m%d', date_sub(current_date(), interval 1 day))
)

select 
    page_title,
    page,
    count(*) as total_pageviews,
    count(distinct concat(user_pseudo_id,"-",session_id)) as unique_pageviews
 
from 
    predata
group by 
    page_title,
    page
order by
    unique_pageviews desc
limit 10
"""

# When changing the function name,
#  please also update the 'source_archive_object' configured
#  in 'google_cloudfunctions_function.default' within 'cloud_functions_main.tf'.
@functions_framework.http
def hello_world(request):
  data = read_data()
  result = "page_title,page,total_pageviews,unique_pageviews\n"
  for row in data:
    result += f"{row.page_title},{row.page},{row.total_pageviews},{row.unique_pageviews}\n"
  print(result)
  return result


def read_data():
  job_config = bigquery.QueryJobConfig()
  query_job = client.query(
  query,
  job_config=job_config,
  )
  
  results = query_job.result()
  return results
