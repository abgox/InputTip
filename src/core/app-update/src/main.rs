use std::fmt::Write as FmtWrite;
use std::process::Command;
use std::{env, fs};

fn main() {
    let args: Vec<String> = std::env::args().collect();

    if args.len() < 4 {
        eprintln!(
            "Usage: {} <process_name> <target_exe_path> <key_count>",
            args[0]
        );
        std::process::exit(1);
    }

    let process_name = &args[1];
    let target_exe_path = &args[2];
    let key_count = &args[3];
    let dir = env::current_dir()
        .expect("Failed to get current directory")
        .join("temp");

    let mut errors = String::new();

    // 终止当前正在运行的 InputTip 进程
    if let Err(e) = Command::new("taskkill")
        .args(&["/f", "/im", process_name])
        .status()
    {
        writeln!(errors, "Failed to execute taskkill: {}", e).unwrap();
    }

    // 将新版本的 exe 文件复制到目标路径
    let new_version_path = dir.join("abgox-InputTip-new-version.exe");
    let copy_ok = if let Err(e) = fs::copy(&new_version_path, target_exe_path) {
        writeln!(errors, "Failed to copy new version: {}", e).unwrap();
        false
    } else {
        true
    };

    // 删除源文件
    if copy_ok {
        if let Err(e) = fs::remove_file(&new_version_path) {
            writeln!(errors, "Failed to delete source file: {}", e).unwrap();
        }
    }

    // 创建完成标记文件（只有复制成功才创建）
    if copy_ok {
        let done_file_path = dir.join("abgox-InputTip-update-version-done.txt");
        if let Err(e) = fs::write(&done_file_path, "") {
            writeln!(errors, "Failed to create done file: {}", e).unwrap();
        }
    }

    // 运行 InputTip.exe
    if let Err(e) = Command::new(target_exe_path).arg(key_count).spawn() {
        writeln!(errors, "Failed to start target executable: {}", e).unwrap();
    }

    // 如果有错误，写入日志文件
    if !errors.is_empty() {
        let log_path = dir.join("abgox-InputTip-update-error.log");
        fs::create_dir_all(&dir).expect("Failed to create data directory");
        fs::write(&log_path, &errors).expect("Failed to write error log");
    }
}
