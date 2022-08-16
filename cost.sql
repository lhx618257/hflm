WITH TB1 AS (  --------------门店数据 ----- 此表由库中每天早上八点定时任务调用PROC_DISH_COST生成
  SELECT IDATE,DOORCODE,DOORNAME, AREANAME,MCRP19,ETE58RP03,XIAOLEI,DISHCODE, DISHNAME,DISHPRICE,SALECOUNT,POSTSALES,PRESALES ,unPOSTSALES,DISHCOST,RENGONG,
         row_number()over(partition by DOORCODE,DISHCODE order by IDATE DESC) RN
   FROM JDEREPORT.COSTPERSON_DETAIL
  WHERE IDATE BETWEEN '2022-06-26' AND '2022-06-26'
  )
SELECT T1.IDATE, -- 日期
       T1.DOORCODE,  -- 门店编码
       T2.DOORNAME,  -- 门店名称
       T2.BIGAREANAME, -- 大区
       T2.AREANAME, -- 小区
       T2.MCRP19, -- 区域编码
       T1.DISHCODE,  -- 产品编码
       T2.DISHNAME, -- 产品名称
       T2.TS_WM, -- 堂食/外卖
       T4.CHH_DEPARTNAME, -- 菜品分类
       DISHPRICE, -- 销售价
       T2.ETE58RP03,  -- 门店小类编码
       T2.XIAOLEI, -- 门店小类
       SALECOUNT, -- 销量
       POSTSALES,-- 营业净收入
       PRESALES ,  -- 营业收入
       round(POSTSALES/1.06,2) unPOSTSALES, -- 营业净收入(不含税)
       ROUND(DISHCOST,2) DISHCOST, -- 成本额
       ROUND(RENGONG,2) RENGONG  -- 人工制费
 FROM TB1 T1 ----- 此表由库中每天早上八点定时任务调用PROC_DISH_COST生成
 JOIN (SELECT DOORCODE,DOORNAME, AREANAME,MCRP19,ETE58RP03,XIAOLEI,DISHCODE,DISHNAME,
              DECODE(SUBSTR(MCRP19,1,1),1,'华东区',2,'华中区',3,'华北区',4,'华南区',5,'华西区',9,'财神面区',6,'小面小酒区',NULL) BIGAREANAME,
              CASE WHEN DISHNAME='虚拟菜品' or ((DISHNAME LIKE '%外%' OR DISHNAME LIKE '%WM%') AND DOORCODE NOT IN ('100519','300560')) THEN '外卖' ELSE '堂食' END TS_WM
         FROM TB1 WHERE RN=1) T2 ON T1.DOORCODE=T2.DOORCODE AND T1.DISHCODE=T2.DISHCODE
 LEFT JOIN JDEREPORT.CONF_NOTJM_MCU T ON SUBSTR(T1.DOORCODE,1,3)=T.CCCO
 LEFT JOIN (SELECT distinct EAT_XFCODE,CHH_DEPARTNAME FROM POS_DISH_DATA PD JOIN POS_DISH_TYPE PT ON PT.CHH_DEPARTID = PD.CHH_DEPARTID) T4 ON T1.DISHCODE=T4.EAT_XFCODE
WHERE 1=1
ORDER BY T1.IDATE,T2.MCRP19,T1.DOORCODE,DISHCODE