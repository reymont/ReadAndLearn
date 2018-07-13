

D:\workspace\jenkins\pipeline-stage-view-plugin\ui\src\main\js\view\templates\pipeline-staged.hbs


边框显示时间

<div class="stage-start-time">
  <div class="date">{{formatDate this.startTimeMillis 'month'}} {{formatDate this.startTimeMillis 'dom'}}</div>
  <div class="time">{{formatDate this.startTimeMillis 'time'}}</div>
</div>