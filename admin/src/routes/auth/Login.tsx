import React from 'react';
import { Link } from 'react-router-dom';
import { useLoginForm } from '../../hooks/useLoginForm';

const Login: React.FC = () => {
  const {
    loginType,
    setLoginType,
    isLoggedIn,
    showAccountMenu,
    userName,
    toggleAccountMenu,
    handleLogout,
    register,
    handleSubmit,
    errors,
    onSubmit
  } = useLoginForm();

  return (
<<<<<<< HEAD
    <div className="w-full min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-blue-100 relative">
      {/* Account Management Box */}
      <div className="absolute top-4 right-4">
        <div className="relative">
          <button
            onClick={toggleAccountMenu}
            className="flex items-center space-x-2 bg-white px-3 py-2 rounded-lg shadow-sm hover:shadow-md transition-all duration-200"
          >
            <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white">
              {isLoggedIn ? userName.substring(0, 1).toUpperCase() : '?'}
            </div>
            <span className="text-sm font-medium text-gray-700">
              {isLoggedIn ? userName : 'Khách'}
            </span>
            <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
            </svg>
          </button>
          
          {showAccountMenu && (
            <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 z-10">
              {isLoggedIn ? (
                <>
                  <div className="px-4 py-2 border-b">
                    <p className="text-sm font-medium text-gray-700">{userName}</p>
                    <p className="text-xs text-gray-500">{loginType === 'admin' ? 'Quản trị viên' : 'Khách hàng'}</p>
                  </div>
                  <button 
                    onClick={handleLogout}
                    className="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100"
                  >
                    Đăng xuất
                  </button>
                </>
              ) : (
                <div className="px-4 py-2 text-sm text-gray-700">
                  Vui lòng đăng nhập
                </div>
              )}
            </div>
          )}
        </div>
      </div>

      <div className="max-w-md w-full bg-white rounded-xl shadow-lg p-8 transition-all duration-300 hover:shadow-xl">
        <div className="text-center mb-8">
          <h2 className="text-3xl font-bold text-gray-800 mb-2">
            Đăng nhập
          </h2>
          <p className="text-gray-600">
            Vui lòng đăng nhập để tiếp tục
          </p>
=======
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-100 via-white to-cyan-100">
      <div className="w-full max-w-md p-8 bg-white rounded-3xl shadow-2xl border-2 border-blue-100">
        <div className="flex flex-col items-center mb-8">
          <img src="/logo.png" alt="Logo" className="h-16 w-16 mb-2 drop-shadow-lg" />
          <h2 className="text-3xl font-extrabold text-blue-800 mb-2 drop-shadow">Đăng nhập</h2>
          <p className="text-blue-700 font-medium">Chào mừng bạn quay lại hệ thống!</p>
>>>>>>> nghia
        </div>
        
        <div className="flex bg-gray-100 p-1 rounded-lg mb-6">
          <button
            onClick={() => setLoginType('admin')}
            className={`flex-1 py-2 rounded-md text-center transition-all ${
              loginType === 'admin' 
                ? 'bg-white text-blue-600 shadow-sm font-medium' 
                : 'text-gray-500 hover:text-gray-700'
            }`}
          >
            Admin
          </button>
          <button
            onClick={() => setLoginType('client')}
            className={`flex-1 py-2 rounded-md text-center transition-all ${
              loginType === 'client' 
                ? 'bg-white text-blue-600 shadow-sm font-medium' 
                : 'text-gray-500 hover:text-gray-700'
            }`}
          >
            Client
          </button>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          <div>
            <label className="block text-blue-700 font-semibold mb-1">Tên đăng nhập</label>
            <input
              {...register('username')}
              className="w-full px-4 py-3 rounded-xl border-2 border-blue-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-100 outline-none transition-all text-lg bg-blue-50 placeholder:text-blue-300"
              placeholder="Nhập tên đăng nhập"
            />
            {errors.username && (
              <span className="text-red-500 text-sm mt-1">{errors.username.message}</span>
            )}
          </div>
          <div>
            <label className="block text-blue-700 font-semibold mb-1">Mật khẩu</label>
            <input
              type="password"
              {...register('password')}
              className="w-full px-4 py-3 rounded-xl border-2 border-blue-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-100 outline-none transition-all text-lg bg-blue-50 placeholder:text-blue-300"
              placeholder="Nhập mật khẩu"
            />
            {errors.password && (
              <span className="text-red-500 text-sm mt-1">{errors.password.message}</span>
            )}
          </div>
          <button
            type="submit"
            className="w-full py-3 bg-gradient-to-r from-blue-600 to-cyan-500 text-white font-bold rounded-xl shadow-lg hover:scale-105 hover:shadow-xl transition-all text-lg border-2 border-transparent hover:border-blue-700"
          >
            Đăng nhập
          </button>
        </form>
        <div className="flex justify-between mt-6 text-sm">
          <Link to="/register" className="text-blue-600 hover:underline font-semibold">Chưa có tài khoản?</Link>
          <Link to="/forgot" className="text-blue-400 hover:underline">Quên mật khẩu?</Link>
        </div>
      </div>
    </div>
  );
};

export default Login;