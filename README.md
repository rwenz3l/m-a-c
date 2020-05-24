# m-a-c
`Memory-Assisted-Copy` is a small shell script wrapper around rclone+sqlite that remembers already copied top-level-directories.

Helps if you need to copy some files from a static location somewhere else where it is going to be moved around,
but you still want that automated workflow as well. Now you can. We copy the file over to the target and remember it's
name inside the database. If it encounters the name again, it will skip it. Might be a bit slower due to the lack of parallel
processing, but that is the sacrifice you make when you want to remember stuff, right?
