# SVN usage notes
29/Jul/2026

## Re-clonning trunk to an existing branch
```batch
svn checkout --depth empty svn://server/repo/branches wc
cd wc
svn update --depth empty oldbranch     # brings just this one node into the WC
svn rm oldbranch
svn cp ^/trunk oldbranch
svn commit -m "Re-branch oldbranch from trunk@HEAD"
```