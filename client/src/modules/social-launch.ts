import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class SocialLaunchClient {
  constructor(private handle: ProgramHandle) {}

  async initializeSocialConfig(accounts: { socialConfig: Address; authority: Address },
    args: { verifierAuthority: Address; requireVerification: number; defaultCurveType: number; defaultCreatorFeeBps: bigint | number; verificationGracePeriod: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("initialize_social_config").accounts({ social_config: accounts.socialConfig, authority: accounts.authority })
      .args({ verifier_authority: args.verifierAuthority, require_verification: args.requireVerification, default_curve_type: args.defaultCurveType, default_creator_fee_bps: args.defaultCreatorFeeBps, verification_grace_period: args.verificationGracePeriod }).rpc();
  }

  async updateSocialConfig(accounts: { socialConfig: Address; authority: Address },
    args: { newVerifier: Address; newRequireVerification: number; newDefaultFeeBps: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("update_social_config").accounts({ social_config: accounts.socialConfig, authority: accounts.authority })
      .args({ new_verifier: args.newVerifier, new_require_verification: args.newRequireVerification, new_default_fee_bps: args.newDefaultFeeBps }).rpc();
  }

  async launchFromTweet(accounts: { socialLaunchRecord: Address; socialConfig: Address; creator: Address },
    args: { mint: Address; tweetIdHash: Address; authorHandleHash: Address; creatorFeeBps: bigint | number; curveType: number }) {
    const p = await this.handle.getProgram();
    return p.method("launch_from_tweet").accounts({ social_launch_record: accounts.socialLaunchRecord, social_config: accounts.socialConfig, creator: accounts.creator })
      .args({ mint: args.mint, tweet_id_hash: args.tweetIdHash, author_handle_hash: args.authorHandleHash, creator_fee_bps: args.creatorFeeBps, curve_type: args.curveType }).rpc();
  }

  async verifyTweet(accounts: { tweetVerification: Address; socialLaunchRecord: Address; socialConfig: Address; verifier: Address },
    args: { tweetIdHash: Address; authorHandleHash: Address; verified: number }) {
    const p = await this.handle.getProgram();
    return p.method("verify_tweet").accounts({ tweet_verification: accounts.tweetVerification, social_launch_record: accounts.socialLaunchRecord, social_config: accounts.socialConfig, verifier: accounts.verifier })
      .args({ tweet_id_hash: args.tweetIdHash, author_handle_hash: args.authorHandleHash, verified: args.verified }).rpc();
  }

  async revokeVerification(accounts: { tweetVerification: Address; socialLaunchRecord: Address; socialConfig: Address; authority: Address }) {
    const p = await this.handle.getProgram();
    return p.method("revoke_verification").accounts({ tweet_verification: accounts.tweetVerification, social_launch_record: accounts.socialLaunchRecord, social_config: accounts.socialConfig, authority: accounts.authority }).args({}).rpc();
  }

  async getTotalSocialLaunches(accounts: { socialConfig: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_total_social_launches").accounts({ social_config: accounts.socialConfig }).args({}).rpc();
  }
}
