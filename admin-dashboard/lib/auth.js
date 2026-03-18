// lib/auth.js - Authentication helpers for admin dashboard
import { useState, useEffect } from 'react';
import { auth, db } from './firebase';
import { onAuthStateChanged, signInWithEmailAndPassword, signOut } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';

export function useAdminAuth() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isAdmin, setIsAdmin] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        try {
          // Check if user has admin role
          const userDoc = await getDoc(doc(db, 'users', user.uid));
          const userData = userDoc.data();
          
          if (userData?.role === 'admin') {
            setIsAdmin(true);
            setUser({
              ...user,
              ...userData
            });
          } else {
            setIsAdmin(false);
            setError('Unauthorized: Admin access required');
            await signOut(auth);
          }
        } catch (err) {
          setError(err.message);
          setIsAdmin(false);
        }
      } else {
        setUser(null);
        setIsAdmin(false);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const login = async (email, password) => {
    try {
      setError(null);
      const result = await signInWithEmailAndPassword(auth, email, password);
      return { success: true, user: result.user };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    }
  };

  const logout = async () => {
    try {
      await signOut(auth);
      return { success: true };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    }
  };

  return { user, isAdmin, loading, error, login, logout };
}

export function requireAdmin(Component) {
  return function ProtectedComponent(props) {
    const { user, isAdmin, loading } = useAdminAuth();
    const router = useRouter();

    useEffect(() => {
      if (!loading && (!user || !isAdmin)) {
        router.push('/login');
      }
    }, [user, isAdmin, loading]);

    if (loading) {
      return (
        <div className="min-h-screen bg-[#0A0A0F] flex items-center justify-center">
          <div className="text-white">Loading...</div>
        </div>
      );
    }

    if (!user || !isAdmin) {
      return null;
    }

    return <Component {...props} />;
  };
}
