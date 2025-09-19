// 用戶數據類型定義

export interface UserStats {
  records: number;
  followers: number;
  following: number;
}

export interface UserData {
  name: string;
  username: string;
  bio: string;
  avatar: string;
  joinDate: string;
  stats: UserStats;
}

export interface LoginModalProps {
  isVisible: boolean;
  onClose?: () => void;
  onLoginSuccess?: (userData: UserData) => void;
}