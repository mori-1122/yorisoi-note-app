department_names = %w[
  内科
  外科
  小児科
  皮膚科
  耳鼻咽喉科
  眼科
  整形外科
  泌尿器科
  循環器科
  脳神経外科
  心療内科
  リハビリテーション科
  産婦人科
]

department_names.each do |name|
  Department.find_or_create_by!(name: name)
end