package org.cocos2dx.plugin;

import android.support.v7.app.AppCompatActivity;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.util.Log;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.auth.api.Auth;
import com.google.android.gms.auth.api.signin.GoogleSignInResult;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.ResultCallback;

import com.google.android.gms.tasks.OnCompleteListener;
import android.support.annotation.NonNull;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.*;

import java.util.Hashtable;

import android.app.ProgressDialog;

/**
 * Created by senspark-dev5 on 9/12/17.
 */

public class UserGoogleSignIn implements InterfaceUser, PluginListener, GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener {

    protected GoogleApiClient mGoogleApiClient;
    protected Context mContext;
    protected UserGoogleSignIn mAdapter;

    protected FirebaseAuth mAuth;
    protected  FirebaseUser user;

    protected GoogleSignInAccount acct;

    private static final int RC_SIGN_IN = 0;
    private static final int RESULT_OK = -1;

    /* Is there a ConnectionResult resolution in progress? */
    private boolean mIsResolving = false;

    /* Should we automatically resolve ConnectionResults when possible? */
    private static boolean mShouldResolve = false;


    public UserGoogleSignIn(Context context) {
        mContext = context;
        mAdapter = this;
        PluginWrapper.addListener(this);

        mAuth = FirebaseAuth.getInstance();
        user = mAuth.getCurrentUser();

        GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestIdToken("375671338821-e28njc1djjjk613odggrlmupfgvl9bl1.apps.googleusercontent.com")
                .requestId()
                .requestProfile()
                .requestEmail()
                .build();


        mGoogleApiClient = new GoogleApiClient.Builder(mContext)
                //.enableAutoManage(this /* FragmentActivity */, this /* OnConnectionFailedListener */)
                .addApi(Auth.GOOGLE_SIGN_IN_API, gso)
                .addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .build();

    }

    @Override
    public void configDeveloperInfo(Hashtable<String, String> cpInfo) {
    }

    @Override
    public void login() {
        Intent signInIntent = Auth.GoogleSignInApi.getSignInIntent(mGoogleApiClient);
        ((Activity)mContext).startActivityForResult(signInIntent, RC_SIGN_IN);
    }

    @Override
    public void logout() {

        mAuth.signOut();
        user = null;

        if (mGoogleApiClient.isConnected()) {
            Auth.GoogleSignInApi.signOut(mGoogleApiClient).setResultCallback(
                    new ResultCallback<Status>() {
                        @Override
                        public void onResult(@NonNull Status status) {
                            UserWrapper.onActionResult(mAdapter, UserWrapper.ACTION_RET_LOGOUT_SUCCEED, "GoogleSignIn logout");
                        }
                    });
        }
        else
        {
            UserWrapper.onActionResult(mAdapter, UserWrapper.ACTION_RET_LOGOUT_SUCCEED, "GoogleSignIn logout");
        }

    }

    @Override
    public boolean isLoggedIn() {
        return user != null;

    }

    @Override
    public void onStart() {
        mGoogleApiClient.connect();

    }

    @Override
    public void onResume() {
    }

    @Override
    public void onPause() {
    }

    @Override
    public void onStop() {
        mGoogleApiClient.disconnect();
        hideProgressDialog();
    }

    @Override
    public void onDestroy() {
    }

    @Override
    public void onBackPressed() {
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {

        if (requestCode == RC_SIGN_IN) {
            GoogleSignInResult result = Auth.GoogleSignInApi.getSignInResultFromIntent(data);

            if (result.isSuccess()) {

                acct = result.getSignInAccount();
                firebaseAuthWithGoogle(acct);

            } else {

                UserWrapper.onActionResult(mAdapter, UserWrapper.ACTION_RET_LOGIN_FAILED, "UserGoogleSignIn: Login failed");

            }
        }

        return true;
    }

    private void firebaseAuthWithGoogle(GoogleSignInAccount acct) {

        showProgressDialog();

        AuthCredential credential = GoogleAuthProvider.getCredential(acct.getIdToken(), null);
        mAuth.signInWithCredential(credential)
                .addOnCompleteListener((Activity) mContext, new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        if (task.isSuccessful()) {
                            user = mAuth.getCurrentUser();
                            UserWrapper.onActionResult(mAdapter, UserWrapper.ACTION_RET_LOGIN_SUCCEED, "UserGoogleSignIn: Login succeeded");

                        } else {

                            UserWrapper.onActionResult(mAdapter, UserWrapper.ACTION_RET_LOGIN_FAILED, "UserGoogleSignIn: Login failed");
                        }

                        hideProgressDialog();
                    }
                });
    }

    @Override
    public String getSessionID() {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public String getUserID() {
        //return user.getUid();
        return acct.getId();
    }

    @Override
    public String getUserAvatarUrl() {

        return user.getPhotoUrl().toString();
    }

    @Override
    public String getUserDisplayName() {

        return user.getDisplayName();
    }

    @Override
    public void setDebugMode(boolean debug) {
        // TODO Auto-generated method stub

    }

    @Override
    public String getSDKVersion() {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public String getPluginVersion() {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {
        // An unresolvable error has occurred and Google APIs (including Sign-In) will not
        // be available.
        Log.d("UserGoogleSignIn", "onConnectionFailed:" + connectionResult);
    }

    @Override
    public void onConnected(Bundle connectionHint) {
        if (mShouldResolve) {
            mShouldResolve = false;
        }

    }

    @Override
    public void onConnectionSuspended(int cause) {
        // TODO Auto-generated method stub

    }
    //-----------------------------------------------------------
    private ProgressDialog mProgressDialog;

    private void showProgressDialog() {
        if (mProgressDialog == null) {
            mProgressDialog = new ProgressDialog(mContext);
            mProgressDialog.setMessage("loading...");
            mProgressDialog.setIndeterminate(true);
        }

        mProgressDialog.show();
    }

    private void hideProgressDialog() {
        if (mProgressDialog != null && mProgressDialog.isShowing()) {
            mProgressDialog.dismiss();
        }
    }


}
