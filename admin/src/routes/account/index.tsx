import React, { useState } from 'react';
import { DashboardLayout } from '../../components/layout/DashboardLayout';

interface UserAccount {
  id: string;
  code: string;
  username: string;
  role: 'Admin' | 'Staff';
  createdDate: string;
  updatedDate: string;
}

const AccountPage: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');

  // Mock data for user accounts
  const accounts: UserAccount[] = [
    {
      id: '1',
      code: 'ACC001',
      username: 'admin.user',
      role: 'Admin',
      createdDate: '15/01/2024',
      updatedDate: '20/01/2024'
    },
    {
      id: '2',
      code: 'ACC002',
      username: 'staff.user',
      role: 'Staff',
      createdDate: '16/01/2024',
      updatedDate: '19/01/2024'
    }
  ];

  const filteredAccounts = accounts.filter(account => 
    account.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
    account.code.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <DashboardLayout>
      <div className="bg-white rounded-3xl shadow-xl p-8 border-2 border-blue-100">
        <h1 className="text-3xl font-extrabold text-blue-800 mb-8 drop-shadow uppercase tracking-wide">Quản lý tài khoản</h1>
        <div className="flex flex-wrap gap-4 mb-8 justify-between items-center">
          <input
            type="text"
            placeholder="Tìm kiếm tài khoản..."
            className="flex-1 min-w-[220px] px-4 py-3 border-2 border-blue-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-lg shadow-sm"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          <button className="flex items-center px-5 py-3 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors font-bold text-lg shadow-lg">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 mr-2" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clipRule="evenodd" />
            </svg>
            Thêm tài khoản
          </button>
        </div>
        <div className="overflow-x-auto rounded-2xl shadow-xl border-2 border-blue-100 bg-white">
          <table className="min-w-full bg-white border border-blue-200">
            <thead className="bg-gradient-to-r from-blue-50 to-cyan-50 text-blue-700">
              <tr className="uppercase text-sm">
                <th className="py-3 px-4 text-left">Mã tài khoản</th>
                <th className="py-3 px-4 text-left">Tên đăng nhập</th>
                <th className="py-3 px-4 text-left">Vai trò</th>
                <th className="py-3 px-4 text-left">Ngày tạo</th>
                <th className="py-3 px-4 text-left">Ngày cập nhật</th>
                <th className="py-3 px-4 text-left">Thao tác</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-blue-100">
              {filteredAccounts.map((account) => (
                <tr key={account.id} className="hover:bg-gray-50">
                  <td className="px-4 py-3 text-gray-900 font-semibold">{account.code}</td>
                  <td className="px-4 py-3 text-gray-900 font-semibold">{account.username}</td>
                  <td className="px-4 py-3">
                    <span className={`px-3 py-1 rounded-full text-xs font-bold shadow-lg ${account.role === 'Admin' ? 'bg-blue-100 text-blue-800' : 'bg-green-100 text-green-800'}`}>{account.role}</span>
                  </td>
                  <td className="px-4 py-3 text-gray-800">{account.createdDate}</td>
                  <td className="px-4 py-3 text-gray-800">{account.updatedDate}</td>
                  <td className="px-4 py-3 space-x-2">
                    <button className="px-3 py-1 text-xs font-bold text-blue-600 hover:text-blue-800 bg-blue-50 rounded-lg">Sửa</button>
                    <button className="px-3 py-1 text-xs font-bold text-red-600 hover:text-red-800 bg-red-50 rounded-lg">Xóa</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </DashboardLayout>
  );
};

export default AccountPage;