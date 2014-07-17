\setrandom id3 1 100000
BEGIN;
SELECT * FROM exemplo1 a JOIN exemplo2 b ON a.c1=b.c1 JOIN exemplo3 c ON a.c2=c.c2 JOIN exemplo4 d ON c.c2=d.c2 WHERE c.c3 = :id3;
END;
