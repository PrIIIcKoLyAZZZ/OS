#!/bin/bash
input_file="process_info.txt"
output_file="process_info_with_avg.txt"

awk -F" : " '
function output_group(ppid, sum, count) {
    avg = sum / count;
    printf "Average_Running_Children_of_ParentID=%s is %f\n", ppid, avg
}
{
  # Извлекаем PPID и ART из строки
  split($2, a, "="); current_ppid = a[2];
  split($3, b, "="); current_art = b[2];
  
  # Если первая строка, инициализируем группу
  if (NR == 1) {
      prev_ppid = current_ppid;
  }
  
  # Если встретилась новая группа, сначала выводим накопленные данные предыдущей группы
  if (current_ppid != prev_ppid) {
      output_group(prev_ppid, group_sum, group_count);
      group_sum = 0;
      group_count = 0;
      prev_ppid = current_ppid;
  }
  print $0;
  group_sum += current_art;
  group_count++;
}
END {
    if (group_count > 0)
        output_group(prev_ppid, group_sum, group_count);
}' "$input_file" > "$output_file"
