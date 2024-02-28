// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./ERC721.sol";

// This contract manages users, groups, and posts, integrating NFT functionality.
contract Twitter {
    // Contract state variables
    address owner; // The owner of the contract.
    uint groupCount; // Total number of groups created.
    uint postCount; // Total number of posts created.
    Post[] posts; // Dynamic array of posts.
    uint deletedPostsCount; // Count of deleted posts to manage the array size dynamically.
    mapping(uint => uint) deletedGroupPostsCount; // Count of deleted posts per group.
    mapping(address => uint) tokenCount; // Tracks the number of tokens per address.
    mapping(address => User) users; // Mapping of user addresses to User structs.
    mapping(uint => Group) groups; // Mapping of group IDs to Group structs.
    mapping(address => NFT) nfts; // Mapping of NFT addresses to NFT contract instances.

    // Post structure with details about each post.
    struct Post {
        address tokenAddress; // The address of the NFT associated with the post.
        uint id; // Unique ID of the post.
        uint tokenId; // Token ID of the associated NFT.
        string tokenUri; // URI of the associated NFT.
        string title; // Title of the post.
        string description; // Description of the post.
        address author; // Address of the post's author.
        bool deleted; // Flag indicating if the post is deleted.
        bool valid; // Flag indicating if the post is valid.
    }

    // Group structure with details about each group.
    struct Group {
        bool valid; // Flag indicating if the group is valid.
        uint id; // Unique ID of the group.
        address tokenAddress; // The address of the NFT associated with the group.
        address owner; // Address of the group's owner.
        string name; // Name of the group.
        string description; // Description of the group.
        Post[] posts; // Dynamic array of posts within the group.
    }

    // User structure with details about each user.
    struct User {
        address id; // Address of the user.
        string name; // Name of the user.
        bool authenticated; // Flag indicating if the user is authenticated.
    }

    // Modifiers for function access control.
    modifier OnlyOwner() {
        require(msg.sender == owner, "NOT OWNER");
        _;
    }

    modifier CheckUserExist() {
        require(users[msg.sender].authenticated, "UNAUTHORIZED");
        _;
    }

    modifier TokenAddressExist(address _addr) {
        require(address(nfts[_addr]) != address(0), "INVALID TOKEN ADDRESS");
        _;
    }

    // Constructor sets the contract's owner to the deployer.
    constructor() {
        owner = msg.sender;
    }

    // Allows the owner to create a new NFT contract instance with specified symbol and name.
    function createNFT(string calldata _symbol, string calldata _name) external OnlyOwner returns (address) {
        NFT newNFT = new NFT(_symbol, _name); // Create a new NFT contract instance.
        nfts[address(newNFT)] = newNFT; // Store the NFT contract instance in the mapping.
        return address(newNFT); // Return the address of the new NFT contract.
    }

    // Allows a new user to sign up with a specified name.
    function signUp(string calldata _name) external {
        User storage newUser = users[msg.sender]; // Reference the User struct for the caller.
        require(!newUser.authenticated, "ACCOUNT REGISTERED"); // Ensure the user hasn't already signed up.
        newUser.id = msg.sender; // Set the user's address.
        newUser.authenticated = true; // Authenticate the user.
        newUser.name = _name; // Set the user's name.
    }

    // Allows an authenticated user to create a new post with specified details and an associated NFT.
    function createPost(address tokenAddress, string calldata title, string calldata description, string calldata tokenUri) external CheckUserExist TokenAddressExist(tokenAddress) {
        postCount++; // Increment the total post count.
        tokenCount[tokenAddress] += 1; // Increment the token count for the specified address.
        nfts[tokenAddress].mint(tokenCount[tokenAddress], tokenUri); // Mint a new NFT for the post.
        posts.push(Post({ // Add the new post to the posts array.
            tokenAddress: tokenAddress,
            id: postCount,
            tokenId: tokenCount[tokenAddress],
            title: title,
            description: description,
            author: msg.sender,
            tokenUri: tokenUri,
            deleted: false,
            valid: true
        }));
    }

    // Allows a user to create a new group with specified details and an associated NFT.
    function createGroup(address tokenAddress, string calldata groupName, string calldata description) external {
        groupCount++; // Increment the total group count.
        Group storage newGroup = groups[groupCount]; // Reference the new Group struct.
        newGroup.description = description; // Set the group's description.
        newGroup.name = groupName; // Set the group's name.
        newGroup.id = groupCount; // Set the group's ID.
        newGroup.owner = msg.sender; // Set the group's owner to the caller.
        newGroup.valid = true; // Mark the group as valid.
        newGroup.tokenAddress = tokenAddress; // Associate an NFT with the group.
    }

    // Allows an authenticated user to create a new post within a specified group, with an associated NFT.
    function createGroupPost(address tokenAddress, string calldata title, string calldata description, string calldata tokenUri, uint groupId) external CheckUserExist TokenAddressExist(tokenAddress) {
        require(groups[groupId].valid, "INVALID GROUP"); // Ensure the specified group is valid.
        postCount++; // Increment the total post count.
        tokenCount[tokenAddress] += 1; // Increment the token count for the specified address.
        nfts[tokenAddress].mint(tokenCount[tokenAddress], tokenUri); // Mint a new NFT for the post.
        groups[groupId].posts.push(Post({ // Add the new post to the specified group's posts array.
            tokenAddress: tokenAddress,
            id: postCount,
            tokenId: tokenCount[tokenAddress],
            title: title,
            description: description,
            author: msg.sender,
            tokenUri: tokenUri,
            deleted: false,
            valid: true
        }));
    }

    // Allows the owner or the author to delete a post by its ID.
    function deletePost(uint postId) external {
        require(posts[postId - 1].valid, "INVALID POST"); // Ensure the post is valid.
        require(msg.sender == owner || msg.sender == posts[postId - 1].author, "NOT AUTHORIZED"); // Ensure the caller is authorized.
        posts[postId - 1].deleted = true; // Mark the post as deleted.
        posts[postId - 1].valid = false; // Mark the post as invalid.
        deletedPostsCount++; // Increment the count of deleted posts.
    }

    // Allows the owner or the group owner to delete a post within a specified group by its ID.
    function deleteGroupPost(uint groupId, uint postId) external {
        require(groups[groupId].valid, "INVALID GROUP"); // Ensure the group is valid.
        require(groups[groupId].posts[postId - 1].valid, "INVALID POST"); // Ensure the post is valid.
        require(msg.sender == owner || msg.sender == groups[groupId].owner, "NOT AUTHORIZED"); // Ensure the caller is authorized.
        groups[groupId].posts[postId - 1].deleted = true; // Mark the post as deleted.
        groups[groupId].posts[postId - 1].valid = false; // Mark the post as invalid.
        deletedGroupPostsCount[groupId]++; // Increment the count of deleted posts for the specified group.
    }
}
