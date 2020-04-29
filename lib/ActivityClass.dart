class Activity {
  String id;
  String title;
  String start_times;
  String end_times;
  String recurring;
  String repetition;
  String priority;
  String privacy;
  String duration;
  Activity(this.end_times, this.priority, this.privacy, this.recurring, this.repetition, this.duration,this.start_times, this.title, this.id);

  Activity.fromJson(Map<String, dynamic> json) {
    title = json["activity"]["title"].toString();
    start_times = json["activity"]["start_times"].toString();
    end_times = json["activity"]["end_times"].toString();
    recurring = json["activity"]["recurring"].toString();
    repetition = json["activity"]["repetition"].toString();
    priority = json["priority"].toString();
    privacy = json["privacy"].toString();
    id = json["activity"]["id"].toString();
    duration = json["activity"]["durations"].toString();
  }
}