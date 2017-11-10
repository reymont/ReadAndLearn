

http://docs.gitlab.com/ce/api/projects.html#search-for-projects-by-name

Search for projects by name 
Search for projects by name which are accessible to the authenticated user. This endpoint can be accessed without authentication if the project is publicly accessible.

GET /projects
Attribute	Type	Required	Description
search	string	yes	A string contained in the project name
order_by	string	no	Return requests ordered by id, name, created_at or last_activity_at fields
sort	string	no	Return requests sorted in asc or desc order
curl --header "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" https://gitlab.example.com/api/v4/projects?search=test