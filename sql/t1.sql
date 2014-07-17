\setrandom id1 1000 1500
\setrandom id2 1501 2000
BEGIN;
SELECT * FROM exemplo1 a JOIN exemplo2 b ON a.c1=b.c1 WHERE b.c1 BETWEEN :id1 AND :id2;
END;
